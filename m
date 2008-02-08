From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] flow: reorder "struct flow_cache_entry" and remove
 SLAB_HWCACHE_ALIGN
Date: Thu, 07 Feb 2008 23:31:04 -0800 (PST)
Message-ID: <20080207.233104.112504375.davem@davemloft.net>
References: <47AC00F1.9090308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758226AbYBHHae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 02:30:34 -0500
In-Reply-To: <47AC00F1.9090308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 Feb 2008 08:12:49 +0100

> 1) We can shrink sizeof(struct flow_cache_entry) by 8 bytes on 64bit arches.
> 2) No need to align these structures to hardware cache lines, this only waste 
>   ram for very litle gain.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
