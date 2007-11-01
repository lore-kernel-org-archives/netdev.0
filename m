From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] Cleanup the allocation/freeing of the sock object
Date: Thu, 01 Nov 2007 00:34:08 -0700 (PDT)
Message-ID: <20071101.003408.174393032.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<47288754.70307@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754071AbXKAHeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:34:09 -0400
In-Reply-To: <47288754.70307@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:47:00 +0300

> The sock object is allocated either from the generic cache with
> the kmalloc, or from the proc->slab cache.
> 
> Move this logic into an isolated set of helpers and make the
> sk_alloc/sk_free look a bit nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
