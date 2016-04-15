From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fixes for SO_REUSEPORT and mixed v4/v6 sockets
Date: Thu, 14 Apr 2016 21:18:02 -0400 (EDT)
Message-ID: <20160414.211802.2280436220533771683.davem@davemloft.net>
References: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbcDOBSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:18:04 -0400
In-Reply-To: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 12 Apr 2016 13:11:24 -0400

> From: Craig Gallek <kraig@google.com>
> 
> Recent changes to the datastructures associated with SO_REUSEPORT broke
> an existing behavior when equivalent SO_REUSEPORT sockets are created
> using both AF_INET and AF_INET6.  This patch series restores the previous
> behavior and includes a test to validate it.
> 
> This series should be a trivial merge to stable kernels (if deemed
> necessary), but will have conflicts in net-next.  The following patches
> recently replaced the use of hlist_nulls with hlists for UDP and TCP
> socket lists:
> ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
> 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> 
> If this series is accepted, I will send an RFC for the net-next change
> to assist with the merge.

Applied and patch #1 queued up for -stable.
