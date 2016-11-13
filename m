From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v13 0/8] openvswitch: support for layer 3
 encapsulated packets
Date: Sun, 13 Nov 2016 00:51:22 -0500 (EST)
Message-ID: <20161113.005122.1783476186953021414.davem@davemloft.net>
References: <cover.1478791347.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@ovn.org,
        lojakab@cisco.com, simon.horman@netronome.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbcKMFv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 00:51:28 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 10 Nov 2016 16:28:16 +0100

> At the core of this patch set is removing the assumption in Open vSwitch
> datapath that all packets have Ethernet header.
> 
> The implementation relies on the presence of pop_eth and push_eth actions
> in datapath flows to facilitate adding and removing Ethernet headers as
> appropriate. The construction of such flows is left up to user-space.
> 
> This series is based on work by Simon Horman, Lorand Jakab, Thomas Morin and
> others. I kept Lorand's and Simon's s-o-b in the patches that are derived
> from v11 to record their authorship of parts of the code.

Series applied, thanks.
