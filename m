From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: de-inline some helper functions
Date: Thu, 03 Nov 2011 18:12:21 -0400 (EDT)
Message-ID: <20111103.181221.937202740160630303.davem@davemloft.net>
References: <1320266081-1387-1-git-send-email-olof@lixom.net>
	<20111102.163658.136546552375950246.davem@davemloft.net>
	<20111102210049.GA3697@quad.lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab1KCWMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 18:12:25 -0400
In-Reply-To: <20111102210049.GA3697@quad.lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olof Johansson <olof@lixom.net>
Date: Wed, 2 Nov 2011 14:00:49 -0700

> This popped some compiler errors due to mismatched prototypes. Just
> remove most manual inlines, the compiler should be able to figure out
> what makes sense to inline and not.
> 
> net/packet/af_packet.c:252: warning: 'prb_curr_blk_in_use' declared inline after being called
> net/packet/af_packet.c:252: warning: previous declaration of 'prb_curr_blk_in_use' was here
> net/packet/af_packet.c:258: warning: 'prb_queue_frozen' declared inline after being called
> net/packet/af_packet.c:258: warning: previous declaration of 'prb_queue_frozen' was here
> net/packet/af_packet.c:248: warning: 'packet_previous_frame' declared inline after being called
> net/packet/af_packet.c:248: warning: previous declaration of 'packet_previous_frame' was here
> net/packet/af_packet.c:251: warning: 'packet_increment_head' declared inline after being called
> net/packet/af_packet.c:251: warning: previous declaration of 'packet_increment_head' was here
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> Cc: Chetan Loke <loke.chetan@gmail.com>

Looks good, applied, thanks Olof.
