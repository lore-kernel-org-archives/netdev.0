From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/8] mlxsw: Allow flow based forwarding in OVS
Date: Thu, 20 Apr 2017 15:32:51 -0400 (EDT)
Message-ID: <20170420.153251.1035391690167407970.davem@davemloft.net>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947084AbdDTTcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:32:53 -0400
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Apr 2017 16:55:30 +0200

> This patchset does some fixes so the HW is setup correctly to do
> flow-based (ACL based) forwarding for OVS-enslaved port.
> 
> The first patch is just trivial fix spotted on the way.
> 
> Patches 2-4 take care of proper FID setup which HW needs in order to
> for ACL based forwarding.
> 
> The 7th patch (with dependency of patch 5 and 6) takes care of proper setup
> of ports that are enslaved in OVS.
> 
> The last patch implements new FID miss trap that is used to push
> packets belonging to unknown flows to kernel and userspace.

Series applied, thanks Jiri.
