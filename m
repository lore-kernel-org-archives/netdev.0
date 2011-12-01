From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 1/4] nfc: Use standard logging styles
Date: Thu, 1 Dec 2011 20:09:41 +0100
Message-ID: <20111201190941.GJ22609@sortiz-mobl>
References: <cover.1322595343.git.joe@perches.com>
 <6c89a76ddb76926febe36fe5be514cb186e39a76.1322595343.git.joe@perches.com>
 <20111201155951.GF22609@sortiz-mobl>
 <1322765318.30801.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322765318.30801.9.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Thu, Dec 01, 2011 at 10:48:38AM -0800, Joe Perches wrote:
> > I would be fine with moving to pr_debug, but I'd like the pr_fmt() routine to
> > include the function name as well.
> 
> If you really want it I can add it back but
> if you are not aware, dynamic debug can add
> this by using:
> 
> echo "module nfc +fp" > <debugfs>/dynamic_debug/control
> echo "module nci +fp" > <debugfs>/dynamic_debug/control
Yes, I'm aware of that.

 
> If you're getting dmesg logs from customers
> that's a bit harder to track though.
Exactly. I'd prefer to have the __func__ being part of the pr_fmt().

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
