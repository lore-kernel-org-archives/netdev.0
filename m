From: kuznet@ms2.inr.ac.ru
Subject: Re: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL != 0xFFFFFFFF)
Date: Thu, 16 May 2002 18:59:51 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205161459.SAA22026@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0205161543400.12674-100000@luxik.cdi.cz>
Mime-Version: 1.0
Cc: davem@sex.inr.ac.ru (Dave Miller), netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: devik@cdi.cz (Martin Devera)
In-Reply-To: <Pine.LNX.4.44.0205161543400.12674-100000@luxik.cdi.cz> from "Martin Devera" at May 16, 2 03:52:43 pm
List-Id: netdev.vger.kernel.org

Hello!

> echo -e "#if ~0UL == 0xffffffff\nTST\n#endif"|gcc -E -
> echo -e "#if ~0UL == 0xffffffffffffffff\nTST\n#endif"|gcc -E -
> 
> and the second line displays TST !!

With old good 2.7.2 this worked...

Dave, do you know a theory explaining this change in gcc behavior?

Alexey
