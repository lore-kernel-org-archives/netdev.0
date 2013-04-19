From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] net: vlan: add support for 802.1ad
Date: Fri, 19 Apr 2013 14:47:40 -0400 (EDT)
Message-ID: <20130419.144740.1231334347687908792.davem@davemloft.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab3DSSrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:47:43 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 19 Apr 2013 14:04:26 +0200

> The following patches add support for 802.1ad (provider tagging) to the
> VLAN driver. The patchset consists of the following parts:
> 
> - renaming of the NET_F_HW_VLAN feature flags to indicate that they only
>   operate on CTAGs
> 
> - preparation for 802.1ad VLAN filtering offload by adding a proto argument
>   to the rx_{add,kill}_vid net_device_ops callbacks
> 
> - preparation of the VLAN code to support multiple protocols by making the
>   protocol used for tagging a property of the VLAN device and converting
>   the device lookup functions accordingly
> 
> - second step of preparation of the VLAN code by making the packet tagging
>   functions take a protocol argument
> 
> - introducation of 802.1ad support in the VLAN code, consisting mainly of
>   checking for ETH_P_8021AD in a couple of places and testing the netdevice
>   offload feature checks to take the protocol into account
> 
> - announcement of STAG offloading capabilities in a couple of drivers for
>   virtual network devices
> 
> The patchset is based on net-next.git and has been tested with single and
> double tagging with and without HW acceleration (for CTAGs).
> 
> If there are no objections, please apply. Thanks!

Great work, all applied to net-next with some whitespace problems fixed.

Thanks!
