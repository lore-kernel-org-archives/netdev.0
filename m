From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 23:26:36 -0800
Message-ID: <45E6802C.2090708@linux-foundation.org>
References: <20070228195611.24cf19ee@deepthought>	<45E650F6.4030404@candelatech.com>	<45E67B04.2060702@linux-foundation.org> <20070228.232224.74746939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59662 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933085AbXCAH2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 02:28:19 -0500
In-Reply-To: <20070228.232224.74746939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 28 Feb 2007 23:04:36 -0800
>
>   
>> If an normal application has to use something like raw packet
>> filtering, it seems there is a missing API.
>>     
>
> I'm loosely following this discussion, but Ben mentions DHCP
> and I remember learning the other month that DHCP uses AF_PACKET
> and filtering instead of IP RAW sockets because it needs to get
> the MAC address and RAW sockets don't provide that.
>   
sounds like a socket option would help, the data is already there. Then 
the normal
UDP receive path would work.
