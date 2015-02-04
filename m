From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add skb functions to process remote
 checksum offload
Date: Wed, 04 Feb 2015 13:54:19 -0800 (PST)
Message-ID: <20150204.135419.1287629592476254710.davem@davemloft.net>
References: <1422922054-22996-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933443AbbBDVyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:54:20 -0500
In-Reply-To: <1422922054-22996-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon,  2 Feb 2015 16:07:34 -0800

> This patch adds skb_remcsum_process and skb_gro_remcsum_process to
> perform the appropriate adjustments to the skb when receiving
> remote checksum offload.
> 
> Updated vxlan and gue to use these functions.
> 
> Tested: Ran TCP_RR and TCP_STREAM netperf for VXLAN and GUE, did
> not see any change in performance.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
