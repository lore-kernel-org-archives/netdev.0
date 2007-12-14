From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 14 Dec 2007 14:07:25 +0900
Message-ID: <20071214134745.275B.MOKUNO@sm.sony.co.jp>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <1197560003.2528.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1197560003.2528.36.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 13 Dec 2007 10:33:22 -0500
Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> You'll need to emit more NULL IWAP events on association failure.  For
> example, gelic_wl_assoc_worker() should probably send one right before
> both instances of 'goto scan_lock_out' in that function (the first where
> there are no scan results, and the second where no compatible BSS can be
> found).  Also, gelic_wl_associate_bss() needs to send a disassociation
> event in the failure case where it sets GELIC_WL_ASSOC_STAT_DISCONN.

Thank you for your reviewing.

I'll fix and submit revised version in next week.

-- 
Masakazu MOKUNO
