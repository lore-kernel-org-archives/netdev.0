From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: nlmon: flag nlmon devs with LLTX/SG
Date: Fri, 28 Mar 2014 16:50:20 -0400 (EDT)
Message-ID: <20140328.165020.652650182875672818.davem@davemloft.net>
References: <1395934499-29092-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbaC1UuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:50:22 -0400
In-Reply-To: <1395934499-29092-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 27 Mar 2014 16:34:59 +0100

> As in xmit path we merely update statistics and free the skb, we
> can mark the device with LLTX feature, so that upper layers can
> avoid taking the single txq lock on xmit. While at it, also add
> missing NETIF_F_SG.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
