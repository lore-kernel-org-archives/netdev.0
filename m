From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: do not disconnect socket when peer has shutdown
 SEND only
Date: Thu, 05 May 2016 23:32:08 -0400 (EDT)
Message-ID: <20160505.233208.1854080809719423732.davem@davemloft.net>
References: <1462368113-5493-1-git-send-email-ian.campbell@docker.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com,
	imbrenda@linux.vnet.ibm.com, acking@vmware.com, dtor@vmware.com,
	jhansen@vmware.com, aditr@vmware.com
To: ian.campbell@docker.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbcEFDcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 23:32:11 -0400
In-Reply-To: <1462368113-5493-1-git-send-email-ian.campbell@docker.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@docker.com>
Date: Wed,  4 May 2016 14:21:53 +0100

> The peer may be expecting a reply having sent a request and then done a
> shutdown(SHUT_WR), so tearing down the whole socket at this point seems
> wrong and breaks for me with a client which does a SHUT_WR.
> 
> Looking at other socket family's stream_recvmsg callbacks doing a shutdown
> here does not seem to be the norm and removing it does not seem to have
> had any adverse effects that I can see.
> 
> I'm using Stefan's RFC virtio transport patches, I'm unsure of the impact
> on the vmci transport.
> 
> Signed-off-by: Ian Campbell <ian.campbell@docker.com>

Applied and queued up for -stable, thanks.
