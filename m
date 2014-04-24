From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 3/4] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Thu, 24 Apr 2014 13:05:11 -0400 (EDT)
Message-ID: <20140424.130511.290213979715404948.davem@davemloft.net>
References: <1398209420-3817-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, edumazet@google.com, maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758599AbaDXRFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:05:13 -0400
In-Reply-To: <1398209420-3817-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 22 Apr 2014 16:30:20 -0700

> Re-organized the xmit function for the lb mode separating tlb xmit
> from the alb mode. This will enable use of the hashing policies
> like 802.3ad mode. Also extended use of xmit-hash-policy to tlb mode.
> 
> Now the tlb-mode defaults to BOND_XMIT_POLICY_LAYER2 if the xmit policy
> module parameter is not set (just like 802.3ad, or Xor mode).
> 
> Change-Id: I140257403d272df75f477b380207338d0f04963e
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
