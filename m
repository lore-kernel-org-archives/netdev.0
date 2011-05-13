From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2 RESEND v3] net: use NETIF_F_ALL_TSO for
 vlan features
Date: Thu, 12 May 2011 23:04:56 -0400 (EDT)
Message-ID: <20110512.230456.2300204421860335018.davem@davemloft.net>
References: <4DCBAE3B.3070201@cn.fujitsu.com>
	<4DCC1372.3040607@chelsio.com>
	<4DCC930D.80805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org, eilong@broadcom.com,
	leedom@chelsio.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1EMDFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 23:05:11 -0400
In-Reply-To: <4DCC930D.80805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 13 May 2011 10:10:21 +0800

> Dimitris Michailidis wrote, at 2011年05月13日 01:05:
>> But vlan_features doesn't indicate by itself what the device supports, and it is because of this that you can use NETIF_F_ALL_TSO in vlan_features without much future breakage risk.  There's still the potential that in the future some additional TSO variant will be added that some of the drivers you're changing support, but not over VLANs, and then they'll need to undo you change.
>  
> For this part.
> 
> David, please discard this patch.

Shan I've discarded all of your patches in this series.
