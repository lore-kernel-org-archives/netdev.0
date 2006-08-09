From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add_timer -> mod_timer() in dst_run_gc()
Date: Wed, 09 Aug 2006 02:26:12 -0700 (PDT)
Message-ID: <20060809.022612.18310364.davem@davemloft.net>
References: <44D9A46C.9070108@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, dim@sw.ru,
	devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39089
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030608AbWHIJ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 05:26:08 -0400
To: dev@openvz.org
In-Reply-To: <44D9A46C.9070108@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@openvz.org>
Date: Wed, 09 Aug 2006 13:01:32 +0400

> F.e. timer has fired on CPU2, but the handler was preeempted
> by an irq before dst_lock is tried.
> Meanwhile, someone on CPU1 adds an entry to gc list and
> starts the timer.
> If CPU2 was preempted long enough, this timer can expire
> simultaneously with resuming timer handler on CPU1, arriving
> exactly to the situation described.

Makes sense.

Patch applied, thanks.
