From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] macsec: set actual real device for xmit when
 !protect_frames
Date: Fri, 1 Jul 2016 13:32:51 +0200
Message-ID: <9975023e-b4e9-15b6-4a7c-11577f1de69d@stressinduktion.org>
References: <920063998328f5014b267defd80eec862f181ad8.1467323773.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47850 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066AbcGALcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 07:32:53 -0400
In-Reply-To: <920063998328f5014b267defd80eec862f181ad8.1467323773.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.07.2016 00:00, Daniel Borkmann wrote:
> Avoid recursions of dev_queue_xmit() to the wrong net device when
> frames are unprotected, since at that time skb->dev still points to
> our own macsec dev and unlike macsec_encrypt_finish() dev pointer
> doesn't get updated to real underlying device.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
