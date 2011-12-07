From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Time in Queue, bufferbloat, and... our accidentally
 interplanetary network
Date: Wed, 7 Dec 2011 10:59:45 +0100
Message-ID: <CAA93jw6w1KAUwW0_TTwCuAScMnq1+RUQzLGZsRqPy_txPGbcjw@mail.gmail.com>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	<1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAJ-VmomuA7u5=zRGMK2Jd3WG+HWTRTZNST4JDVWU9kUEcfE91Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ-VmomuA7u5=zRGMK2Jd3WG+HWTRTZNST4JDVWU9kUEcfE91Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2011 at 3:03 AM, Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org> wrote=
:
> Hi,
>
> For what it's worth, I've also been tinkering with time-in-queue for
> the wifi queue management in FreeBSD. I don't have anything public
> yet. What I have done actually seems to work quite well, when doing T=
X
> queue time-in-queue management. (I'm ignoring RX queue management for
> now.)
>
> Yes, I think a weighted random drop with both time-in-queue and queue
> depth would work well. I haven't sat down to model what it'd look lik=
e
> given some traffic profiles.
>
> I'll be sure to post some patches and results when I have them. :)

Well, if there is a way to add BQL sanely to the mac80211 or driver
layers and then apply some time in queue techniques at some edge
of some layer(s) down there in Linux, I'd love to know what and where
is good.

It might be simpler to discuss design ideas etc, in a more generic
and less noisy forum than netdev and linux-wireless, at least
for a while, getting to actual patches seems kind of hard at this point=
=2E

(at least to me. For all I know eric is finished already, and me, I hav=
en't
 finished grokking the paper he's leveraging some ideas on)

The little I understand about Linux's networking stack dwarfs the
little I know about BSD's, so I look forward to hearing about your
results as you get them, and that said, if you could provide some
pointers and insight into BSD's traffic shaping methods over on
bloat-devel, we do try to be all-architecture embracing in our
attempts to beat the bloat.

>
>
> Adrian



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
