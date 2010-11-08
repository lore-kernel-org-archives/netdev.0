From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 8 Nov 2010 10:43:59 +0100
Message-ID: <20101108094358.GA22069@basil.fritz.box>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
 <1289172456.3090.184.camel@Dan>
 <20101107235610.GE17592@basil.fritz.box>
 <20101107.180108.71121019.davem@davemloft.net>
 <1289201612.2478.371.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	drosenberg@vsecurity.com, chas3@users.sourceforge.net,
	tytso@mit.edu, torvalds@linux-foundation.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56810 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab0KHJoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 04:44:04 -0500
Content-Disposition: inline
In-Reply-To: <1289201612.2478.371.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When a printk() happens right before a BUG(), how are we going to check
> the dumped registers are possibly close the socket involved, if we dont
> have access to the machine, and only the crashlog ?

Is that really something you do regularly? It seems highly obscure
to me.

Besides if the kernel has timestamps enabled you can easily
guess based on the timestamps if the printk and the oops
are related.

-Andi
