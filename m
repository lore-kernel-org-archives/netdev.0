From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump() into functions
Date: Thu, 5 Jan 2012 10:41:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF2F@saturn3.aculab.com>
References: <1325720472.4116.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<ath6kl-devel@qualcomm.com>, <davem@davemloft.net>
To: "Joe Perches" <joe@perches.com>,
	"Kalle Valo" <kvalo@qca.qualcomm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1325720472.4116.7.camel@joe2Laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> > +	va_start(args, fmt);
> > +	ath6kl_printk(KERN_DEBUG, fmt, &args);
> 
> Passing a va_list as an argument?
> I believe this doesn't work.
> I think you'll need to add and use:

Passing a va_list certainly does work - vprintf() etc.
What is problematical is taking the address of a va_list.

The likely problem is a 'levels of indirection' one
because, when va_list needs to be a struct (very
likely when arguments are passed in registers),
it is often declared as as array type.

	David
