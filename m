From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Mon, 11 Jun 2007 13:42:57 +0200
Message-ID: <466D3541.8020904@trash.net>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com> <466826C6.6000206@openvz.org> <46682976.8050904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40473 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbXFKLpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 07:45:22 -0400
In-Reply-To: <46682976.8050904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Pavel Emelianov wrote:
> 
>>> I would also like some way to identify veth from other device types,
>>> preferably
>>> something like a value in sysfs.   However, that should not hold up
>>>     
>>
>>
>> We can do this with ethtool. It can get and print the driver name of
>> the device.
>>   
> 
> I think I'd like something in sysfs that we could query for any
> interface.  Possible return
> strings could be:
> VLAN
> VETH
> ETH
> PPP
> BRIDGE
> AP /* wifi access point interface */
> STA /* wifi station */
> ....
> 
> I will cook up a patch for consideration after veth goes in.


The rtnl_link API gives you the name of the driver (IFLA_INFO_KIND).

