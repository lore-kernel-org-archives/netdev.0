From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: upcall: Fix vlan handling.
Date: Tue, 27 Dec 2016 12:29:51 -0500 (EST)
Message-ID: <20161227.122951.662506742518657444.davem@davemloft.net>
References: <1482769887-8022-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarno@ovn.org, jbenc@redhat.com
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755850AbcL0R3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 12:29:52 -0500
In-Reply-To: <1482769887-8022-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Mon, 26 Dec 2016 08:31:27 -0800

> Networking stack accelerate vlan tag handling by
> keeping topmost vlan header in skb. This works as
> long as packet remains in OVS datapath. But during
> OVS upcall vlan header is pushed on to the packet.
> When such packet is sent back to OVS datapath, core
> networking stack might not handle it correctly. Following
> patch avoids this issue by accelerating the vlan tag
> during flow key extract. This simplifies datapath by
> bringing uniform packet processing for packets from
> all code paths.
> 
> Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets").
> CC: Jarno Rajahalme <jarno@ovn.org>
> CC: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
