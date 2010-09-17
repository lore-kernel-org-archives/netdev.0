From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 2/5] qlcnic: vlan gro support
Date: Fri, 17 Sep 2010 11:25:51 -0700 (PDT)
Message-ID: <20100917.112551.37567808.davem@davemloft.net>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	<1284700483-16397-3-git-send-email-amit.salecha@qlogic.com>
	<20100917.112455.191154697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361Ab0IQSZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 14:25:32 -0400
In-Reply-To: <20100917.112455.191154697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 17 Sep 2010 11:24:55 -0700 (PDT)

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Date: Thu, 16 Sep 2010 22:14:40 -0700
> 
>> @@ -796,7 +796,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
>>  	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
>>  			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
>>  	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
>> -			NETIF_F_IPV6_CSUM);
>> +			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
>>  
>>  	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
>>  		features |= (NETIF_F_TSO | NETIF_F_TSO6);
>> @@ -1456,7 +1456,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
>>  	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
>>  		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
>>  	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
>> -		NETIF_F_IPV6_CSUM);
>> +		NETIF_F_IPV6_CSUM | NETIF_F_GRO);
>>  
>>  	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
> 
> Drivers no longer should set NETIF_F_GRO in their vlan_features
> flags, the generic networking core does this for you now in
> register_netdevice() in net-next-2.6
> 
> Please respin this patch with these settings removed.

Actually, nevermind, I'll take care of doing this for you, just be
aware of this new convention.

Thank you.
