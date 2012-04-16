From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: SV: Netlink, route monitoring, =?UTF-8?Q?RTM=5FDELROUTE=20not?=
 =?UTF-8?Q?=20issued=20for=20ppp=20peer=20address=2E=20Bug=20or=20feature?=
 =?UTF-8?Q?=3F?=
Date: Mon, 16 Apr 2012 22:11:29 +0300
Message-ID: <3c43db7f164f0bee19d98360f58bef38@visp.net.lb>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
 <023e01cd197d$a9faba40$fdf02ec0$@no>
 <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
 <20120416.144005.2201460378756236307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <stian@nixia.no>, <eric.dumazet@gmail.com>,
	<stephen.hemminger@vyatta.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:46280 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2DPTLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 15:11:40 -0400
In-Reply-To: <20120416.144005.2201460378756236307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-04-16 21:40, David Miller wrote:
> From: Denys Fedoryshchenko <denys@visp.net.lb>
> Date: Mon, 16 Apr 2012 13:37:14 +0300
>
>> So the only solution is to fetch first, then keep full routing table
>> in userspace also, and keep tracking if local addresses deleted, and
>> do the same in userspace and check for prefsrc...
>
> You don't need to keep full routing table in userspace, don't be
> silly.
>
> You only need to watch for the device down event, and purge in
> userspace based upon that key.
In my specific case i should. Userspace should just send information 
that some ip came or gone on specific access server, to central node (i 
am not reinventing dynamic routing protocols, there is another reasons 
for that). Central node don't know anything about interfaces. Access 
server i was expecting to not keep anything, and just relay netlink 
routing messages, route to specific ip are appearing and disappearing. 
Because it is not possible i will just keep as you mentioned table, with 
ip+device+prefsrc, and listen to other than routing netlink events.

As i mention before, it is not big deal to do that, and i understood 
that it is not a "netlink/kernel bug", but a reasonable design choice.
I posted it, just to share my view, so in future people who have 
similar question, as Stian Skjelstad had, will have more information.
