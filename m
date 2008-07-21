From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 03:20:37 +0200
Message-ID: <4883E465.4050405@trash.net>
References: <20080720.104411.81744468.davem@davemloft.net>	<alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55425 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640AbYGUBVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:21:25 -0400
In-Reply-To: <20080720.180304.51601407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sun, 20 Jul 2008 17:54:04 -0700 (PDT)
>
>   
>> Grr. And I quote:
>>
>> 	  Security table (IP_NF_SECURITY) [Y/n/?] (NEW) ?
>> 	
>> 	This option adds a `security' table to iptables, for use
>> 	with Mandatory Access Control (MAC) policy.
>> 	
>> 	If unsure, say N.
>>
>> why the heck does this new config option apparently default to 'Y'? It's a 
>> new option, so no old users can need it, and the docs even say you should 
>> say 'N' unless you know what you're doing.
>>
>> (Same issue with the IPv6 version).
>>
>> Don't do this.
>>     
>
> James/Patrick please fix this.
>   

This is only the NETFILTER_ADVANCED=n default (for SECURITY=y).
The netfilter defaults for NETFILTER_ADVANCED=n should be m/y for
things that are needed by mainstream distributions for normal
usage.

I'm not sure how this is going to be used, James?

