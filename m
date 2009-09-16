From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Fix access to freed memory
Date: Wed, 16 Sep 2009 00:00:29 -0700 (PDT)
Message-ID: <20090916.000029.112056936.davem@davemloft.net>
References: <200909151452.41206.vgusev@openvz.org>
	<adad45sf4nu.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, jackm@dev.mellanox.co.il, rolandd@cisco.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756366AbZIPHAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 03:00:12 -0400
In-Reply-To: <adad45sf4nu.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 15 Sep 2009 11:23:33 -0700

> 
>  > catas_reset() uses pointer to mlx4_priv, but mlx4_priv is not valid after
>  > call mlx4_restart_one().
>  > 
>  > Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 
> Good catch.  Dave, if you want me to take this, let me know, otherwise:
> 
> Acked-by: Roland Dreier <rolandd@cisco.com>

I've got it, thanks everyone.
