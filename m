From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: update checksum in {push,pop}_mpls
Date: Tue, 31 May 2016 13:52:03 -0700 (PDT)
Message-ID: <20160531.135203.2078504589397948891.davem@davemloft.net>
References: <1464584665-8512-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org, pshelar@nicira.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcEaUwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 16:52:07 -0400
In-Reply-To: <1464584665-8512-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 30 May 2016 14:04:25 +0900

> In the case of CHECKSUM_COMPLETE the skb checksum should be updated in
> {push,pop}_mpls() as they the type in the ethernet header.
> 
> As suggested by Pravin Shelar.
> 
> Cc: Pravin Shelar <pshelar@nicira.com>
> Fixes: 25cd9ba0abc0 ("openvswitch: Add basic MPLS support to kernel")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2
> * Use helper to reduce duplicated code.

Applied, thanks Simon.
