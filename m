From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mlx4: Fix access to freed memory
Date: Tue, 15 Sep 2009 11:23:33 -0700
Message-ID: <adad45sf4nu.fsf@cisco.com>
References: <200909151452.41206.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Roland Dreier <rolandd@cisco.com>, netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:39777 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZIOSXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 14:23:31 -0400
In-Reply-To: <200909151452.41206.vgusev@openvz.org> (Vitaliy Gusev's message
	of "Tue, 15 Sep 2009 14:52:40 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > catas_reset() uses pointer to mlx4_priv, but mlx4_priv is not valid after
 > call mlx4_restart_one().
 > 
 > Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

Good catch.  Dave, if you want me to take this, let me know, otherwise:

Acked-by: Roland Dreier <rolandd@cisco.com>
