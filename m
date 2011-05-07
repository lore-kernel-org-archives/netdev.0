From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 19:50:52 +0100
Message-ID: <52426C6458B2FEE35EF69E4A@Ximines.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>	
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:35172 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955Ab1EGSu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 14:50:56 -0400
In-Reply-To: <1304793749.3207.26.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 7 May 2011 20:42:29 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Here is my trace here for one device deletion on one 8 core machine
>
> [  800.447012] synchronize_rcu() in 15787 us
> [  800.455013] synchronize_rcu() in 7682 us
> [  800.464019] rcu_barrier() in 8487 us

Would you mind trying it with my script to do veth devices? kill udev and do
unshare -n first.

I've done this on 2 different lots of hardware now, with 3 kernels 18
months apart.

$ grep RCU .config
# RCU Subsystem
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set


-- 
Alex Bligh
