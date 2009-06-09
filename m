From: Patrick McHardy <kaber@trash.net>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Tue, 09 Jun 2009 12:59:03 +0200
Message-ID: <4A2E4077.8080407@trash.net>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com> <20090608.143454.161329513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gil.beniamini@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59816 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046AbZFIK7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 06:59:04 -0400
In-Reply-To: <20090608.143454.161329513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Gil Beniamini <gil.beniamini@gmail.com>
> Date: Mon, 8 Jun 2009 21:05:25 +0300
> 
>> My application is using PF_PACKET and SOCK_RAW in order to receive all
>> Ethernet packets for the machine-unicast MAC plus all broadcast
>> packets (like ARP broadcast).
> 
>> That worked OK with kernel 2.6.20 (Ubuntu 7.04 with or without VLAN).
>>
>> Now with kernel 2.6.28 (Ubuntu 9.04) it works OK only without-VLAN,
>> but with VLAN the application receive only packets for the
>> machine-unicast MAC, but no broadcast (like ARP broadcast) packets,
>> only if I set the socket to PROMISC mode, I start receive also
>> broadcast packets.

Which driver are you using? Are you sniffing on the VLAN device
or on the underlying device?

