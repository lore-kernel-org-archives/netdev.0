From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 17:47:32 +0300
Message-ID: <87ocosqykb.fsf@purkki.valot.fi>
References: <200909111648.50902.mb@bu3sch.de>
	<20090929192928.GF2678@tuxdriver.com> <4AC3475C.7000403@hartkopp.net>
	<200909301633.04376.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200909301633.04376.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> (Michael Buesch's message of "Wed\, 30 Sep 2009 16\:33\:02 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> writes:

>> I don't know how expensive in_interrupt() is, but it IMO should be
>> avoided when the context for a code section can be determined in
>> another way.
>
> What if we just get the fix merged and discuss later whether it's
> worth to optimize a picosecond or not?? My patch fixes the _bug_.
> You can merge a more "efficient" fix later that saves one or two CPU
> cycles.

I agree with Michael. The bug is real and I have verified that
Michael's patch fixes the issue. Better to apply the patch now, it's
trivial to change the implementation if/when the network stack has
support for this.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
