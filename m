From: walter harms <wharms@bfs.de>
Subject: Re: [KJ] [patch] net/tipc: sprintf/strcpy conversion
Date: Thu, 02 Nov 2006 08:45:11 +0100
Message-ID: <4549A207.4050102@bfs.de>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc>	<454913D2.9050608@bfs.de> <20061101.151917.133285028.davem@davemloft.net>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@lists.osdl.org,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.fr.bfs.de ([194.95.226.137]:58589 "EHLO mail.fr.bfs.de")
	by vger.kernel.org with ESMTP id S1752715AbWKBHpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 02:45:16 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061101.151917.133285028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



David Miller wrote:
> From: walter harms <wharms@bfs.de>
> Date: Wed, 01 Nov 2006 22:38:26 +0100
> 
>> These line
>> +	strcpy(bcbearer->media.name, "tipc-multicast");
>>
>> i gues that means tipc_bclink_name ?

mea culpa, i should not write mail when tired.


> 
> Why?  The original code used "tipc-multicast" which is a
> different string than tipc_bclink_name which is "multicast-link".
> 
>>> -	sprintf(bcbearer->media.name, "tipc-multicast");
>>> +	strcpy(bcbearer->media.name, "tipc-multicast");
> 
> If you are arguing that it should be changed, that's a different
> changeset to discuss.
> 
> 
> 
