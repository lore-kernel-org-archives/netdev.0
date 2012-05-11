From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] macvtap: restore vlan header on user read
Date: Fri, 11 May 2012 18:17:51 -0400 (EDT)
Message-ID: <20120511.181751.1371300375721985549.davem@davemloft.net>
References: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: basil.gor@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030254Ab2EKWRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:17:54 -0400
In-Reply-To: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Basil Gor <basil.gor@gmail.com>
Date: Fri,  4 May 2012 12:55:24 +0400

> Ethernet vlan header is not on the packet and kept in the skb->vlan_tci
> when it comes from lower dev. This patch inserts vlan header in user
> buffer during skb copy on user read.
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

Also applied, thanks.
