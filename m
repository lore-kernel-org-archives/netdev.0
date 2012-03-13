From: Ben Greear <greearb@candelatech.com>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Tue, 13 Mar 2012 08:37:42 -0700
Message-ID: <4F5F69C6.7000900@candelatech.com>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com> <20120312193204.5be5b4b8@nehalam.linuxnetplumber.net> <20120313021529.97514922.billfink@mindspring.com> <20120312.235234.73408595516828250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, shemminger@vyatta.com,
	diego@woitasen.com.ar, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50597 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab2CMPhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 11:37:47 -0400
In-Reply-To: <20120312.235234.73408595516828250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2012 11:52 PM, David Miller wrote:
> From: Bill Fink<billfink@mindspring.com>
> Date: Tue, 13 Mar 2012 02:15:29 -0400
>
>> Some scripts may depend on this plus its much more efficent that way
>> if trying to find a matching route since you can quit on the first
>> match instead of having to scan the entire routing table.
>
> No script should be doing stuff like this, let the tool do it for you
> via "ip route get ADDR"
>
> There is absolutely no argument for routes to be listed in one order
> or another, and anything depending upon order is extremely fragile
> and needs to be fixed up anyways.

The argument is ease of use by whatever human is reading the
information..but it could be done in the 'ip' tool.

Humans are fragile indeed, but it's often easier to fix the
computer than fix the humans.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
