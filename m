From: kyeyoonp@codeaurora.org
Subject: Re: [PATCH net-next] bridge: make proxy arp configurable
Date: Wed, 19 Nov 2014 23:11:52 -0000
Message-ID: <9dd8ca1857559a294f99c5849b51c8aa.squirrel@www.codeaurora.org>
References: <20141030200942.5a531e34@urahara>
    <20141031.122133.1697556792716394439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: shemming@brocade.com, kyeyoonp@codeaurora.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:57303 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375AbaKSXLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 18:11:53 -0500
In-Reply-To: <20141031.122133.1697556792716394439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger <shemming@brocade.com>
> Date: Thu, 30 Oct 2014 20:09:42 -0700
>
>> @@ -60,3 +60,19 @@ config BRIDGE_VLAN_FILTERING
>>  	  Say N to exclude this support and reduce the binary size.
>>
>>  	  If unsure, say Y.
>> +
>> +config BRIDGE_ARP_PROXY
>> +	bool "ARP proxying"
>> +	depends on BRIDGE
>> +	depends on INET
>> +	default y
>> +	---help---
>> +	  If you say Y here, then the Ethernet bridge to keep track of
>> +	  the hardware address to IP address mapping.
>> +
>> +	  It is most useful when used as a wireless AP.
>> +
>> +	  Say N to exclude this support and reduce the binary size.
>> +
>> +	  If unsure, say Y.
>> +
>
> Please do not ever add empty lines at the end of files, GIT warns
> about this when I try to apply your patch.

Hi Dave, I notice that this patch was never applied to "net-next". I
have one more patch contribution to make to the bridge code regarding
Proxy ARP IPv4. I would very much like this patch by Stephen to be
applied as well. I have no problem resubmitting this patch (with the
empty line removed). Do you want me to do that as part of the set?

Thanks!

- Kyeyoon
