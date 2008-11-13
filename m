From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: bnx2_alloc_rx_mem() should use kmalloc() for
 small allocations
Date: Wed, 12 Nov 2008 22:49:27 -0800 (PST)
Message-ID: <20081112.224927.250241354.davem@davemloft.net>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
	<1226531404-26118-5-git-send-email-mchan@broadcom.com>
	<491BBFDA.9000303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, mcarlson@broadcom.com,
	benli@broadcom.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYKMGt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 01:49:28 -0500
In-Reply-To: <491BBFDA.9000303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 13 Nov 2008 06:49:14 +0100

> Any chance bnx2_alloc_rx_mem doesnt use vmalloc() to allocate less
> than a page of memory ?
>
> [PATCH] bnx2: bnx2_alloc_rx_mem() should use kmalloc() for small allocations

Eric, I've seen (and used) this idiom enough times that I think
it deserves a generic construct somewhere instead of replicating
this sequence over and over again.

Don't you agree? :-)
