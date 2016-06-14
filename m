From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/3] macsec: allocate sg and iv on the heap
Date: Tue, 14 Jun 2016 16:19:33 +0200
Message-ID: <38ae03e7-4e28-eb8f-2d03-b2017cbc5462@stressinduktion.org>
References: <cover.1465908271.git.sd@queasysnail.net>
 <da30e15d4c309ed7b598b6d0eb12be0436d461a8.1465908271.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59668 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751332AbcFNOTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 10:19:40 -0400
In-Reply-To: <da30e15d4c309ed7b598b6d0eb12be0436d461a8.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2016 15:25, Sabrina Dubroca wrote:
> For the crypto callbacks to work properly, we cannot have sg and iv on
> the stack.  Use kmalloc instead, with a single allocation for
> aead_request + scatterlist + iv.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
