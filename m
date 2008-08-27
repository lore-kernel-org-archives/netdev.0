From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 16:31:03 -0700
Message-ID: <20080827233103.GE5927@tesla>
References: <20080827013009.GA15781@tuxdriver.com> <1ba2fa240808271226i95a7789k481a68b09dc60164@mail.gmail.com> <200808272225.10557.mb@bu3sch.de> <1ba2fa240808271611v382631ecn2a24e2816562d434@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1ba2fa240808271611v382631ecn2a24e2816562d434-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 04:11:15PM -0700, Tomas Winkler wrote:
> if (beacon_timestamp > rx_timestamp)
>     merge
> 
> The patch from Assaf just disable reporting RX timestamp to mac and
> thus disabling merging which gives incorrect spec behavior but smooth
> traffic.

We *should follow the spec*.

> Actually we've checked few cards including broadcom and various
> windows NICs

What are windows NICs?

> and non of them implements this correctly so this WA is
> probably the solution.

Disagreed! If there is hardware which is not capable of handling this
we should simply have a HW flag which specifies this to handle this as a
work around (WA). Just because some cards are not capable it doesn't
mean it should impose that on the rest.

> Other solution would be to mark leader with highest TSF and not
> reconnecting to the same station again and again.
> 
> Last solution would be to remove this merging all together but then
> I'm not sure if Bruno added this code just implement the spec or
> really tested it with any hardware. I'm not sure if any vendor
> implements PS in IBSS so this merging is probably not important
> anyway.

Absolutely not! IBSS merge is per spec, otherwise you don't really have
a real IBSS.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
