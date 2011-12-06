From: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Subject: Re: Time in Queue, bufferbloat, and... our accidentally
 interplanetary network
Date: Tue, 6 Dec 2011 10:03:05 +0800
Message-ID: <CAJ-VmomuA7u5=zRGMK2Jd3WG+HWTRTZNST4JDVWU9kUEcfE91Q@mail.gmail.com>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	<1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

For what it's worth, I've also been tinkering with time-in-queue for
the wifi queue management in FreeBSD. I don't have anything public
yet. What I have done actually seems to work quite well, when doing TX
queue time-in-queue management. (I'm ignoring RX queue management for
now.)

Yes, I think a weighted random drop with both time-in-queue and queue
depth would work well. I haven't sat down to model what it'd look like
given some traffic profiles.

I'll be sure to post some patches and results when I have them. :)



Adrian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
