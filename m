From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the  online CPUs default
Date: Tue, 23 Mar 2010 15:05:31 +0100
Message-ID: <874ok7dtg4.fsf@basil.nowhere.org>
References: <4BA85EA2.1090304@gmail.com>
	<1269329250.3043.19.camel@edumazet-laptop>
	<412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49822 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568Ab0CWOFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 10:05:33 -0400
In-Reply-To: <412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com> (Changli Gao's message of "Tue, 23 Mar 2010 18:03:22 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:
>
> I do think distributing packets fairly among all the online CPUs will
> helps most of users. I remember the smp_affinity of IRQ is the
> online_cpu_mask be default.

The established wisdom is that most apps prefer locality.

The cost of data transfer between CPUs is worse than the 
overhead of processing the packet header in the stack.

That's why no system does interrupt RR by default anymore.

Besides if you do such a change you would need extensive benchmarking
to verify that it's a good idea.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
