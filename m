From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sat, 14 Nov 2009 02:14:21 +0200
Message-ID: <200911140214.21493.opurdila@ixiacom.com>
References: <200911130701.14847.opurdila@ixiacom.com> <200911130720.19671.opurdila@ixiacom.com> <20091113160445.7a3538ef@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19345 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757252AbZKNARW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 19:17:22 -0500
In-Reply-To: <20091113160445.7a3538ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 14 November 2009 02:04:45 you wrote:
> On Fri, 13 Nov 2009 07:20:19 +0200
> 
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> > On Friday 13 November 2009 07:01:14 you wrote:
> > > This patch speeds up the network device name allocation for the case
> > > where a significant number of devices of the same type are created
> > > consecutively.
> > >
> > > Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
> > > and sysfs entries disabled:
> > >
> > > Without the patch           With the patch
> > >
> > > real    0m 43.43s	    real    0m 0.49s
> > > user    0m 0.00s	    user    0m 0.00s
> > > sys     0m 43.43s	    sys     0m 0.48s
> 
> Since the main overhead here is building the bitmap table used in the
> name scan. Why not mantain the bitmap table between calls by
> implementing a rbtree with prefix -> bitmap.
> The tree would have to be limited and per namespace but then you
> could handle the general case of adding a device, then its vlans,
> then another device, ...
> 

I'll do that !

That was my original intent but I thought it would be too much bloat :) But I 
see your point, even if it is more complex, its more useful.

Thanks,
tavi
