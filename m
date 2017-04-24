From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] openvswitch: Add eventmask support to
 CT action.
Date: Mon, 24 Apr 2017 13:53:43 -0400 (EDT)
Message-ID: <20170424.135343.1508947450864961163.davem@davemloft.net>
References: <1492818486-57292-1-git-send-email-jarno@ovn.org>
        <1492818486-57292-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974807AbdDXRxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:53:45 -0400
In-Reply-To: <1492818486-57292-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 21 Apr 2017 16:48:06 -0700

> Add a new optional conntrack action attribute OVS_CT_ATTR_EVENTMASK,
> which can be used in conjunction with the commit flag
> (OVS_CT_ATTR_COMMIT) to set the mask of bits specifying which
> conntrack events (IPCT_*) should be delivered via the Netfilter
> netlink multicast groups.  Default behavior depends on the system
> configuration, but typically a lot of events are delivered.  This can be
> very chatty for the NFNLGRP_CONNTRACK_UPDATE group, even if only some
> types of events are of interest.
> 
> Netfilter core init_conntrack() adds the event cache extension, so we
> only need to set the ctmask value.  However, if the system is
> configured without support for events, the setting will be skipped due
> to extension not being found.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Reviewed-by: Greg Rose <gvrose8192@gmail.com>
> Acked-by: Joe Stringer <joe@ovn.org>

Applied.
