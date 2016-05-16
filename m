From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] xen-netback: support for control ring
Date: Mon, 16 May 2016 13:36:11 -0400 (EDT)
Message-ID: <20160516.133611.976787620871442054.davem@davemloft.net>
References: <1463128649-20832-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbcEPRgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:36:14 -0400
In-Reply-To: <1463128649-20832-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 13 May 2016 09:37:25 +0100

> My recent patch to import an up-to-date include/xen/interface/io/netif.h
> from the Xen Project brought in the necessary definitions to support the
> new control shared ring and protocol. This patch series updates xen-netback
> to support the new ring.
> 
> Patch #1 adds the necessary boilerplate to map the control ring and handle
> messages. No implementation of the new protocol is included in this patch
> so that it can be kept to a reasonable size.
> 
> Patch #2 adds the protocol implementation.
> 
> Patch #3 adds support for passing has values calculated by xen-netback to
> capable frontends.
> 
> Patch #4 adds support for accepting hash values calculated by capable
> frontends and using them the set the socket buffer hash.

Series applied, thanks.
