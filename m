From: Patrick McHardy <kaber@trash.net>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 07 Oct 2008 14:56:03 +0200
Message-ID: <48EB5C63.60501@trash.net>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb> <20081007124820.GG4606@ntm.vs.lam.cz> <200810071549.16647.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Milan Kocian <milon@wq.cz>, Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44877 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYJGM4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:56:11 -0400
In-Reply-To: <200810071549.16647.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> On Tuesday 07 October 2008, Milan Kocian wrote:
>> hello,
>>
>> btw. How can I see vlan id on device ?
>> After:
>> # ip l a l eth0 type vlan id 100
>> # ip a
>> I see:
>>
>> 64: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>>     link/ether 00:16:d3:3e:4e:b9 brd ff:ff:ff:ff:ff:ff
>>
>> No vlan id in interface name ?
>>
>> # ip -V
>> ip utility, iproute2-ss080725
>>
>> regards,
> Use flag -d
> rich ip # ./ip -d l show dev vlan0
> 31: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>     link/ether 00:1e:8c:89:78:af brd ff:ff:ff:ff:ff:ff
>     vlan id 100 <REORDER_HDR>

It would be better to have -d as a default, I was afraid of breaking
scripts of people sedding and awking around with the iproute output.

Stephen should make this call, I'm not sure what guarantees he wants
to provide. I just remembered one of my previous jobs where a large
number of scripts had to be changed because iproute started using
lower case letters in some spots, and I had to do it :)
