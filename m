From: kuznet@ms2.inr.ac.ru
Subject: Re: PROBLEM: udp not delivered on special socket receive buffer size
Date: Wed, 10 Jul 2002 12:56:58 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207100856.MAA25289@sex.inr.ac.ru>
References: <200207100945.13002.welk@fokus.gmd.de>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, davem@redhat.com, pekkas@netcore.fi,
   gober@fokus.gmd.de
Return-path: <owner-netdev@oss.sgi.com>
To: welk@fokus.gmd.de (Matthias Welk)
In-Reply-To: <200207100945.13002.welk@fokus.gmd.de> from "Matthias Welk" at Jul 10, 2 09:45:11 am
List-Id: netdev.vger.kernel.org

HelloQ

> The probles is, that I did not receive any udp packets (224 bytes), if the=
> =20
> receive buffer size (SO_RCVBUF) of the socket is set to a value below 831=20
> (??) bytes.

Apparently, 831 is not enough to allow to queue such buffer.

Tune value of "rx_copybreak" for ethernet to value sort of 1000.
It is module parameter for most of drivers.


> Yes, you may ask why such a low value, but I have no influence on this,=20
> because it is set in the Java Media Framework internally.

No doubts, this piece of software was not ever tested and contains
lots of another bugs, you will get nothing but persistnet pain in ass
if you are going to use it seriously.

Alexey
