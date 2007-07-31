From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 21:30:19 -0700
Message-ID: <46AEBADB.7030007@candelatech.com>
References: <1185843556.5162.8.camel@localhost>	<20070730.183337.27784025.davem@davemloft.net>	<1185847324.5162.31.camel@localhost> <20070730.190621.13770511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60950 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940748AbXGaEfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 00:35:24 -0400
In-Reply-To: <20070730.190621.13770511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Mon, 30 Jul 2007 22:02:04 -0400
>
>   
>> I came across the issue because i used cb in batching to store transient
>> state which is used between qdisc dequeueing and hardware enqueueing
>> (looked and smelled legit to me).
>>     
>
> Right, dequeue->device should be OK and doesn't work because of
> the VLAN issue.
>   

So, shall we add a new field to the skb in order to get the info out of cb?

Looks like a single 32-bit field would be sufficient.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


