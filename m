From: Ben Greear <greearb@candelatech.com>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Thu, 30 Apr 2009 00:48:50 -0700
Message-ID: <49F957E2.8040406@candelatech.com>
References: <30658.1240619463@death.nxdomain.ibm.com>	<49F4BCEB.6040507@candelatech.com>	<13072.1240876558@death.nxdomain.ibm.com> <20090427.183640.182469000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45559 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbZD3HtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 03:49:05 -0400
In-Reply-To: <20090427.183640.182469000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Mon, 27 Apr 2009 16:55:58 -0700
> 
>> I'm reluctant to mess with this behavior without knowing why it
>> works this way; there may be a good reason for it that I'm not aware
>> of.
> 
> To be honest I think it's just that this is one huge dark
> corner of behavior for many virtual devices, rather than
> any of it being intentional.

For what it's worth, I've been using a patch that disables the
behaviour in vlan that brings up/down the interface based on
the underlying device for several years w/out noticeable problems.

However, I may just be getting lucky.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

