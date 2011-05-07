From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 20:42:29 +0200
Message-ID: <1304793749.3207.26.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <178E8895FB84C07251538EF7@Ximines.local>
	 <1304793174.3207.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39789 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab1EGSmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:42:33 -0400
Received: by wya21 with SMTP id 21so3071268wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 11:42:32 -0700 (PDT)
In-Reply-To: <1304793174.3207.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is my trace here for one device deletion on one 8 core machine

[  800.447012] synchronize_rcu() in 15787 us
[  800.455013] synchronize_rcu() in 7682 us
[  800.464019] rcu_barrier() in 8487 us

Not that bad.

$ grep RCU .config
# RCU Subsystem
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_TRACE=y
CONFIG_RCU_FANOUT=32
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y


