From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [Patch 2/3] sysctl: add proc_do_large_bitmap
Date: Fri, 9 Apr 2010 15:35:38 +0300
Message-ID: <201004091535.38714.opurdila@ixiacom.com>
References: <20100409101442.5051.99812.sendpatchset@localhost.localdomain> <20100409101503.5051.3805.sendpatchset@localhost.localdomain> <s2w412e6f7f1004090333g3b23eb94udb1e6cc3939a07e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:4266 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751917Ab0DIMfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 08:35:41 -0400
In-Reply-To: <s2w412e6f7f1004090333g3b23eb94udb1e6cc3939a07e5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 April 2010 13:33:29 you wrote:
> On Fri, Apr 9, 2010 at 6:11 PM, Amerigo Wang <amwang@redhat.com> wrote:
> > From: Octavian Purdila <opurdila@ixiacom.com>
> >
> > The new function can be used to read/write large bitmaps via /proc. A
> > comma separated range format is used for compact output and input
> > (e.g. 1,3-4,10-10).
> >
> > Writing into the file will first reset the bitmap then update it
> > based on the given input.
> 
> We have bitmap_scnprintf() and bitmap_parse_user(), why invent a new suite?
> 

A decimal comma separated ranges seems the best option for this feature, and 
unfortunately both of the above functions only support hexadecimal and no 
ranges.
