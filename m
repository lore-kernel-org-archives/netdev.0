From: kuznet@ms2.inr.ac.ru
Subject: Re: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL !=
Date: Thu, 16 May 2002 21:08:01 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205161708.VAA22517@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0205161723230.12674-100000@luxik.cdi.cz>
Mime-Version: 1.0
Cc: davem@sex.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: devik@cdi.cz (Martin Devera)
In-Reply-To: <Pine.LNX.4.44.0205161723230.12674-100000@luxik.cdi.cz> from "Martin Devera" at May 16, 2 05:25:06 pm
List-Id: netdev.vger.kernel.org

Hello!

> and the HOST_WIDEST_INT is used for all arithmetic in CPP.

This is not answer to the question. This behaviour was proven
experimentally. :-)

One question is _why_. Why the rules are so drastically different
between C and CPP? C in CPP stands for C eventually. I can guess that
this was caused by some problems with cross compiling 64bit <-> 32 bit,
but I still do not understand why the fix was so strange.

Another question is that this does not matter. UL is an explicit type
specifier. In the experession there is no place for ambiguity at least
from viewpoint of C.

Apparently, before doing such strong change of rules it was discussed
among gcc people. It would be intersting to know how it was motivated.

Alexey
