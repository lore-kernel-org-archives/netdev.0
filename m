From: Martin Devera <devik@cdi.cz>
Subject: Re: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL !=
 0xFFFFFFFF)
Date: Thu, 16 May 2002 17:25:06 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205161723230.12674-100000@luxik.cdi.cz>
References: <200205161459.SAA22026@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Miller <davem@sex.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200205161459.SAA22026@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

Btw the text below is from gcc 3.0.2 cpp parser:
/* Find HOST_WIDEST_INT and set its bit size, type and print macros.
   It will be the largest integer mode supported by the host which may
   (or may not) be larger than HOST_WIDE_INT.  This must appear after
   <limits.h> since we only use `long long' if its bigger than a
   `long' and also if it is supported by macros in limits.h.  For old
   hosts which don't have a limits.h (and thus won't include it in
   stage2 cause we don't rerun configure) we assume gcc supports long
   long.)  Note, you won't get these defined if you don't include
   {ht}config.h before this file to set the HOST_BITS_PER_* macros. */

and the HOST_WIDEST_INT is used for all arithmetic in CPP.

On Thu, 16 May 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > echo -e "#if ~0UL == 0xffffffff\nTST\n#endif"|gcc -E -
> > echo -e "#if ~0UL == 0xffffffffffffffff\nTST\n#endif"|gcc -E -
> >
> > and the second line displays TST !!
>
> With old good 2.7.2 this worked...
>
> Dave, do you know a theory explaining this change in gcc behavior?
>
> Alexey
>
>
