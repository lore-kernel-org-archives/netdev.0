From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH/RFC v2] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
	symbol
Date: Thu, 20 Mar 2008 18:03:48 -0400
Message-ID: <20080320220348.GC1330@tuxdriver.com>
References: <1206023695.16475.137.camel@johannes.berg> <20080320181310.GA17884@uranus.ravnborg.org> <1206038373.16475.150.camel@johannes.berg> <20080320.141307.173590705.davem@davemloft.net> <1206048106.16475.161.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org,
	dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1206048106.16475.161.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2008 at 10:21:46PM +0100, Johannes Berg wrote:
> 
> > I think you're semantically testing the wrong thing.
> > 
> > It's not if unaligned accesses are supported, it's if they are
> > efficient enough or not.
> > 
> > For example, sparc64 fully handles unaligned accesses but taking the
> > trap to fix it up is slow.  So sparc64 "can" handle unaligned
> > accesses, but whether we want to set this symbol or not is another
> > matter.
> 
> Yeah, good point. Should I rename it to HAVE_EFFICIENT_UNALIGNED_ACCESS
> or similar? Or have it defined as some sort of number so you can make
> actually make tradeoffs? Like Dave Woodhouse suggested at some point to
> have get_unaligned() take an argument that indicates the probability...

Ugh...that sounds like premature optimization to me...

While I think Dave has a point, I don't think you should labor the word
choice too much.  Try to document it as clearly as possible and hope
for the best -- I hear that the arch maintainers are top notch! :-)

John

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
