From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: avoid double-freeing of rx data memory
Date: Thu, 07 Nov 2013 19:10:10 -0500 (EST)
Message-ID: <20131107.191010.1147344692367468040.davem@davemloft.net>
References: <1383742956-18731-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mchan@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab3KHAKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:10:12 -0500
In-Reply-To: <1383742956-18731-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  6 Nov 2013 14:02:36 +0100

> If build_skb fails the memory associated with the ring buffer is freed but
> the ri->data member is not zeroed in this case. This causes a double-free
> of this memory in tg3_free_rings->... path. The patch moves this block after
> setting ri->data to NULL.
> It would be nice to fix this bug also in stable >= v3.4 trees.
> 
> Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
