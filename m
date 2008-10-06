From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Tue, 07 Oct 2008 00:38:20 +0200
Message-ID: <48EA935C.7090106@trash.net>
References: <20081006173024.2741cc01@speedy> <alpine.LNX.1.10.0810062208370.6758@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYJFWi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:38:27 -0400
In-Reply-To: <alpine.LNX.1.10.0810062208370.6758@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> 
> 
> On Mon, 6 Oct 2008, Stephen Hemminger wrote:
> 
>> Propogate MTU changes of underlying device to all related VLAN
>> devices.
>> see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742
> 
> Not sure about this... Some switches (HP ProCurve for example) allow to 
> select which vlan accepts jumbo frames and which does not and attach 
> both to the same port. It is quite useful as you are able to setup one 
> vlan with jumbo frames dedicated for example to servers connected by 
> 1G/10G links, and a second vlan with standard 1500 MTU distributed to 
> non jumbo-aware switches/workstations.

Thats why I favour the knob to specify the desired behaviour.
Treating a VLAN device as a seperate entity from the ethernet
device which just has the same hardware-imposed restrictions
seems like a valid view to me.

