From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL !=
 0xFFFFFFFF)
Date: Thu, 16 May 2002 16:35:31 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205161634030.10809-100000@mausmaki.cosy.sbg.ac.at>
References: <Pine.LNX.4.44.0205161543400.12674-100000@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.44.0205161543400.12674-100000@luxik.cdi.cz>
List-Id: netdev.vger.kernel.org

--snip/snip
> Probably the test should be changed. I'm not sure how. How to detect
> that long is 64 bit in cpp ?

by using BITS_PER_LONG (which is defined in include/asm/types.h)

	tm

-- 
in some way i do, and in some way i don't.
