From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 00:06:48 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208132006.AAA21878@sex.inr.ac.ru>
References: <1029258874.772.97.camel@tux>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: gandalf@wlug.westbo.se (Martin Josefsson)
In-Reply-To: <1029258874.772.97.camel@tux> from "Martin Josefsson" at Aug 13, 2 07:14:34 pm
List-Id: netdev.vger.kernel.org

Hello!

> Alexey, when you had checksum problems, did you see invalid checksums in
> tcpdump?

No. It is dubiously similar to your case. It is the sibj
"Linux TCP problem while talking to hostme.bkbits.net" in linux-kernel.
It is mistique not less than your case. :-)

> Does anyone else have an idea or suggestion I can try?

Well, let's look what exactly checksum routines calculate on the steps.
Maybe, this will give a clue.

Actually, tulip is really different of another cards, this creature
generates badly aligned packets. F.e. it is possible a checksumming routine
folds some bytes beyond end of frame. :-) I have lots of verious tulips here,
but have never seen such a shit. :-)

Alexey
