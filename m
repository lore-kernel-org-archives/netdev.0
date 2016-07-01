From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: set actual real device for xmit when
 !protect_frames
Date: Fri, 01 Jul 2016 16:36:58 -0400 (EDT)
Message-ID: <20160701.163658.219548351536664342.davem@davemloft.net>
References: <920063998328f5014b267defd80eec862f181ad8.1467323773.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbcGAUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:37:07 -0400
In-Reply-To: <920063998328f5014b267defd80eec862f181ad8.1467323773.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  1 Jul 2016 00:00:54 +0200

> Avoid recursions of dev_queue_xmit() to the wrong net device when
> frames are unprotected, since at that time skb->dev still points to
> our own macsec dev and unlike macsec_encrypt_finish() dev pointer
> doesn't get updated to real underlying device.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
