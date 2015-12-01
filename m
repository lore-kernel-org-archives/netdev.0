From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net: Use after free in dst_release on boot
Date: Tue, 01 Dec 2015 16:04:48 +0100
Message-ID: <1448982288.3372279.454745393.4F634AAE@webmail.messagingengine.com>
References: <5658C188.4050708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Sasha Levin <sasha.levin@oracle.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5658C188.4050708@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Nov 27, 2015, at 21:48, Sasha Levin wrote:
> [  117.057618] BUG: KASAN: use-after-free in dst_release+0x9a/0xc0 at
> addr ffff8806cf7c7560
> 
> [  117.058566] Read of size 2 by task swapper/0/1
> 

Can you check if the following commit was already applied? net wasn't
merged into net-next for a while.

commit d69bbf88c8d0b367cf3e3a052f6daadf630ee566
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Nov 9 17:51:23 2015 -0800

    net: fix a race in dst_release()

Thanks,
Hannes
