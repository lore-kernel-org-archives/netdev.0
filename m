From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump()
 into functions
Date: Thu, 05 Jan 2012 08:30:45 -0800
Message-ID: <1325781045.22154.15.camel@joe2Laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF2F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>, linville@tuxdriver.com,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, ath6kl-devel@qualcomm.com,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF2F@saturn3.aculab.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 10:41 +0000, David Laight wrote:
> > > +	va_start(args, fmt);
> > > +	ath6kl_printk(KERN_DEBUG, fmt, &args);
> > Passing a va_list as an argument?
> > I believe this doesn't work.
> > I think you'll need to add and use:
> Passing a va_list certainly does work - vprintf() etc.
> What is problematical is taking the address of a va_list.

Nope.  This referred to this specific instance.
Taking the address of a va_list works fine.
Look at the provide example.
