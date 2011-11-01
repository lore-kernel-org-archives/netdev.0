From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: print nud_state in neigh timer handler.
Date: Tue, 01 Nov 2011 17:44:11 -0400 (EDT)
Message-ID: <20111101.174411.1200019350687608200.davem@davemloft.net>
References: <1320095448-5228-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	daniel.baluta@gmail.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614Ab1KAVoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 17:44:20 -0400
In-Reply-To: <1320095448-5228-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Mon, 31 Oct 2011 23:10:48 +0200

> From: Daniel Baluta <daniel.baluta@gmail.com>
> 
> For debugging purposes it is useful to know the exact state of a
> non NUD_IN_TIMER neighbour entry whose timer handler just expired.
> 
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

This debugging log message is dubious.

Also, it is protected by !SMP and I can almost guarentee you that whatever
condition makes it happen leigitmately on SMP also can be triggered with
preemption enabled on !SMP.

So I'm going to simply remove this debug message entirely instead.
