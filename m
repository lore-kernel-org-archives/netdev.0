From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 2.6]: IPv4: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 09:42:18 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070012538.10048.13.camel@hades.cambridge.redhat.com>
References: <20031127142125.GG8276@jdj5.mit.edu>
	 <3FC67128.14704.30155D53@localhost>
	 <1069970946.2138.13.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Kamph <timo@kamph.org>,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1069970946.2138.13.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-11-27 at 23:09 +0100, Felipe Alfaro Solana wrote:
> On Thu, 2003-11-27 at 21:48, Timo Kamph wrote:
> 
> > > +	strlcpy(label->label, name, sizeof(label->name));
> >                                                                        ^^^^^^
> > I guess this shoud be label->label, or am I wrong?
> 
> Oh my god! Two consecutive mistakes with the same patch! I should have
> some sleep... Here's the one with the typo corrected.

Perhaps we should consider

#define strsizecpy(x, y) strlcpy((x), (y), sizeof(x))

-- 
dwmw2
