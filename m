From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Tue, 20 Jan 2009 02:04:00 -0800
Message-ID: <4975A190.5050305@chelsio.com>
References: <20090115211403.3792.24995.stgit@speedy5><20090119.170308.145804150.davem@davemloft.net> <20090119.180330.255801668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:23437 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbZATKFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 05:05:21 -0500
In-Reply-To: <20090119.180330.255801668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> I had to add a fix due to some build bustage resulting from
> this change.
> 
> drivers/scsi/cxgb3i/cxgb3i_ddp.h was depending upon the implicit
> inclusion of linux/vmalloc.h coming from the inet_lro.h include
> which is removed by this change.
> 
> In file included from drivers/scsi/cxgb3i/cxgb3i_ddp.c:24:
> drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_alloc_big_mem':
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: error: implicit declaration of function 'vmalloc'
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: warning: assignment makes pointer from integer without a cast
> drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_free_big_mem':
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:157: error: implicit declaration of function 'vfree'
> 
> I'll fix this up.

Oops. Sorry about that. Thanks for fixing it.

Cheers,
Divy
