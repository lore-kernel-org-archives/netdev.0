From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Tue, 03 Jan 2012 12:03:56 -0800
Message-ID: <4F035F2C.1000003@candelatech.com>
References: <4F035BDE.5060409@candelatech.com> <20120103.145931.2188599484081157576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38677 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab2ACUEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:04:02 -0500
In-Reply-To: <20120103.145931.2188599484081157576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/2012 11:59 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Tue, 03 Jan 2012 11:49:50 -0800
>
>> As far as I can tell, no other interfaces are auto-created
>> in this manner.
>
> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
> net/{ipv4,ipv6}/

So, no changing the behaviour?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
