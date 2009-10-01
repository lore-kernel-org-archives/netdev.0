From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 1 Oct 2009 21:10:32 +0200
Message-ID: <200910012110.34216.mb@bu3sch.de>
References: <1254324077.3959.7.camel@johannes.local> <200910011604.42916.mb@bu3sch.de> <1254422548.3959.24.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	kalle.valo-X3B1VOXEql0@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254422548.3959.24.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 01 October 2009 20:42:28 Johannes Berg wrote:
> On Thu, 2009-10-01 at 16:04 +0200, Michael Buesch wrote:
> > On Thursday 01 October 2009 01:33:33 David Miller wrote:
> > 
> > > I'm not applying this until all of these details are sorted out 
> > 
> > John, please apply my fix to wireless-testing to get rid of the regression.
> > You can revert it later, if there's a better fix available.
> 
> I agree with davem, don't. Just fix the driver to local_bh_disable()
> around the rx function if necessary.

For the benefit of a much bigger critical section? I don't get it why this would be any better.

I _am_ going to do one thing now, however. That is ignoring any regression bugreport.
(Yes, it _is_ a regression for b43)

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
