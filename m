From: Ben Greear <greearb@candelatech.com>
Subject: Re: GRE devices and MULTICAST flag.
Date: Fri, 23 Sep 2011 13:42:53 -0700
Message-ID: <4E7CEF4D.6080309@candelatech.com>
References: <4E7CE473.3000304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56422 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab1IWUmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 16:42:53 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p8NKgrhO032124
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 13:42:53 -0700
In-Reply-To: <4E7CE473.3000304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2011 12:56 PM, Ben Greear wrote:
> I was under the impression that GRE tunnels could support MULTICAST
> traffic, but the MULTICAST flag is not set. This is making the xorp
> router crap out because it checks the MULTICAST flag and will
> not start multicast on the interface if it's not set....
>
> Is it supposed to be set?
>
> 7: gre0: <NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
> link/gre 0.0.0.0 brd 0.0.0.0
> 8: netb: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
> link/gre 192.168.100.223 peer 192.168.100.138
> inet 10.0.1.1/32 scope global netb

Well, ifconfig netb multicast seems to add the flag,
so maybe all is as it should be.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
