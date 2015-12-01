From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Use after free in dst_release on boot
Date: Tue, 01 Dec 2015 07:29:38 -0800
Message-ID: <1448983778.25582.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5658C188.4050708@oracle.com>
	 <1448982288.3372279.454745393.4F634AAE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448982288.3372279.454745393.4F634AAE@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-01 at 16:04 +0100, Hannes Frederic Sowa wrote:
> Hi,
> 
> On Fri, Nov 27, 2015, at 21:48, Sasha Levin wrote:
> > [  117.057618] BUG: KASAN: use-after-free in dst_release+0x9a/0xc0 at
> > addr ffff8806cf7c7560
> > 
> > [  117.058566] Read of size 2 by task swapper/0/1
> > 
> 
> Can you check if the following commit was already applied? net wasn't
> merged into net-next for a while.
> 
> commit d69bbf88c8d0b367cf3e3a052f6daadf630ee566
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Nov 9 17:51:23 2015 -0800
> 
>     net: fix a race in dst_release()

Yes, this most definitely is the fix for this problem.

Thanks Hannes !
