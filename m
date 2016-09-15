From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] test_bpf: fix the dummy skb after dissector changes
Date: Thu, 15 Sep 2016 19:17:25 -0400 (EDT)
Message-ID: <20160915.191725.1104138957333806597.davem@davemloft.net>
References: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        hadarh@mellanox.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755491AbcIOXR2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:17:28 -0400
In-Reply-To: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 12 Sep 2016 13:04:57 +0100

> Commit d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan
> info from skb->vlan_tci") made flow dissector look at vlan_proto
> when vlan is present.  Since test_bpf sets skb->vlan_tci to ~0
> (including VLAN_TAG_PRESENT) we have to populate skb->vlan_proto.
> 
> Fixes false negative on test #24:
> test_bpf: #24 LD_PAYLOAD_OFF jited:0 175 ret 0 != 42 FAIL (1 times)
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>

Applied.
