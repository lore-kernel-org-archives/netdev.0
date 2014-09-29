From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Mon, 29 Sep 2014 21:40:42 +0200
Message-ID: <2326963.udog5tteBt@eisbaer>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54258459.8020803@msgid.tls.msk.ru> <54296223.6090702@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2166920.l4ruzGuEIG"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:54284 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaI2TsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 15:48:05 -0400
In-Reply-To: <54296223.6090702@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2166920.l4ruzGuEIG
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Monday 29 September 2014 15:44:03 Arend van Spriel wrote:
> On 09/26/14 17:20, Michael Tokarev wrote:
> > I can send it your way, -- guess it will be quite a bit costly,
> > but I don't have any use for it anyway (short of throwing it
> > away), and since I already spent significantly more money due
> > to all this (whole thinkpad plus ssds and several wifi adaptors),
> > this additional cost is just a small noize.  But since that's
> > 2nd card in a row, maybe there's something else in there, the
> > prob is not in the card?
> 
> Could be. Maybe some BIOS issue. Can you make some hi-res pictures of
> the card and email them to me? If it is identical to what I already have
> over here there is not much sense in sending it.
> 
> Regards,
> Arend

Hi Arend,

I just saw this thread on linux-wireless and wanted to answer as it might be 
of interest to you.

I also own a BCM4313 wireless network card. About a year ago I reported some 
problems with reception strength which were then fixed after some time, 
debugging and testing passed. At that time I also did some throughput testing, 
but only had a 802.11g access-point to test. The results were not ideal, but 
also not too bad. So at that time I thought the issues were all more or less 
fixed and mostly fine. I also don't use wireless very much, so as long as things 
do work somehow acceptable I probably don't notice any problems immediately.
So it comes that only about some month ago I noticed that the throughput I 
measured with my 11g access-point (about half the rate than with an atheros 
card on the same ap) is about the same on a 11n access-point where it should 
be much faster. I didn't experience any stalls, but that may also be that I 
didn't use the card enough to really notice them.

I always wanted to report a bug because of the low throughout, but never got 
to it because of lack of time. I didn't want to provide a report saying just 
it doesn't work or it's slow without any data about it and a description how 
to reproduce it, as I think without this information a bug report is mostly 
useless.

I also had a look at the kernel changelog of the brcmsm driver and notices 
there was little to no activity lately. Because of this I also wasn't sure if 
there is still someone interesting in fixing bugs for this device.

As I was annoyed by the bad support for this card I decided it would be more 
easy and much less time consuming to simply buy another card than trying to 
get this fixed. So I bought a BCM43228 card, because it also supports 5 GHz. 
Only after it arrived I noticed that it was only supported by the 3.17+ kernel 
(not so much of a problem) and that it only seems to work in 802.11g mode 
(only slow speeds and no 5 GHz). At least I could use it in full 11g speeds, 
so it was a improvement.

So I still don't have a card that does simply work. As I hope the missing 
support for my BCM43228 will hopefully be added some time in the future it 
probably would still be worth fixing the BCM4313 card as other users will also 
benefit from it.

A friend of mine also has the same laptop than me and the same (or at least 
very similar) wireless card. He has told me he has also problem with stalls 
like Michael reported (if I remember the history of the thread correctly).

So I'm not really sure where I should go from here. I can try to provide some 
debugging information as time permits, but I don't know how much time I will 
have for this in the future. Of course ideally I want to use the BCM43228 card 
with full support, as it can work on 5 GHz.

Currently the BCM43228 card is plugged into my laptop, but I want to avoid 
swapping the cards more that very few times because the antenna connectors are 
only designed for very few (un)plug cycles.

If it's of any information, my card is labeled BCM-BCM94313HMGB on the 
sticker, the laptop where it was originally is a ThinkPad Edge E135.

Greetings,
Maxi

--nextPart2166920.l4ruzGuEIG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUKbW9AAoJEIHqZH0kK9IV8YQQAKyj7tj7BqoSPWI5JfNj+YiM
+714zrX1bCFKO0kF5KVgKJGp61WYsA56MiQpa6aO9c+CQ1hocqs24Gxkah+za//i
E+v2FV/6BuFfgzS+0lbDJzjxjLYqucAwgOk+OuZCxil1mHfgsiBttJh7BQmv43lY
fTprq6n7WwiCbwkAjDsv06c/+AIDTPZwyMPAXPQcOEVz/xEljJI6Z/toxMZo16Xw
g0r4WqbiGuSD0ULRb5nhi2w1SnprEr/MdQfHfofsleM9th/K2pqQJEX8I8FN7Xvx
GhdTDs78ITEj8FXYCMLrre08bvy1g+Ubw2Qch1/fd9CWt+ux0TB5j5hnnrPWk6gE
PF14YxClfLpJ5O2yH1EDAI78bmbhAABARfkuQPxojn75DGU29iUX33W7OM60FCkB
SD5a8wchFjqPhKfETznZ6cXY1UXJ6IDt6WVIODxGek761Z1sajTLytn0wJxzSQKY
Z4Nn1PBVdwjFuAOLTP2TeQfBGkxreAgs2wWWwxkDV9HsT8+KN56wI9tUfd+0dplD
+iy+mJq1xOBGZ1tc+M/bvQiAHLzaB2Ws/okxdVmwTdXt3nupi2dCoyHWFS6IdrYG
ncXIgVnOg3BN3lqrsrHuqGnpLBVZh9TizsOGWmDT+0k+rQ7aYQg0BrRmz1/jlRsN
39bSUTRsEZ4LCzyynRgk
=U6Xt
-----END PGP SIGNATURE-----

--nextPart2166920.l4ruzGuEIG--
