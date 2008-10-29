From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: propogate ethtool speed values
Date: Tue, 28 Oct 2008 22:12:56 -0700 (PDT)
Message-ID: <20081028.221256.123614778.davem@davemloft.net>
References: <20081028175236.1659315c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60456
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751385AbYJ2FNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:13:18 -0400
In-Reply-To: <20081028175236.1659315c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 28 Oct 2008 17:52:36 -0700

> This enables more ethtool information. The speed and settings of the
> underlying device are propagated up. This makes services like SNMP that
> use ethtool to get speed setting, work when managing a vlan, without adding
> silly heurtistics into SNMP daemon.
> 
> For the driver info, just use existing driver strings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

This looks good to me, applied to net-next-2.6
