From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Add a missing break statement.
Date: Tue, 20 Dec 2016 14:08:23 -0500 (EST)
Message-ID: <20161220.140823.1456160478740611460.davem@davemloft.net>
References: <1482195993-97937-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, pshelar@ovn.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935020AbcLTTIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 14:08:24 -0500
In-Reply-To: <1482195993-97937-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Mon, 19 Dec 2016 17:06:33 -0800

> Add a break statement to prevent fall-through from
> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
> actions setting ethernet addresses fail to validate with log messages
> complaining about invalid tunnel attributes.
> 
> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> Acked-by: Jiri Benc <jbenc@redhat.com>

Applied.
