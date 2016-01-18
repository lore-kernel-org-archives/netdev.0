From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] ovs: limit ovs recursions in
 ovs_execute_actions to not corrupt stack
Date: Sun, 17 Jan 2016 19:26:28 -0500 (EST)
Message-ID: <20160117.192628.1780434341967114696.davem@davemloft.net>
References: <1452876675-19834-1-git-send-email-hannes@stressinduktion.org>
	<CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	simon.horman@netronome.com, eric.dumazet@gmail.com
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbcARA0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:26:30 -0500
In-Reply-To: <CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pravin shelar <pshelar@ovn.org>
Date: Sat, 16 Jan 2016 09:04:50 -0800

> This function always run in soft-irq context. Do we really need this
> preempt-disable call here?

Hannes, please respond to this feedback.

Thanks.
