From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Fri, 08 Jun 2007 20:00:10 +0400
Message-ID: <46697D0A.40006@openvz.org>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com> <466826C6.6000206@openvz.org> <46682976.8050904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9802 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761755AbXFHP5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 11:57:19 -0400
In-Reply-To: <46682976.8050904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

[snip]

>>> I would also like some way to identify veth from other device types,
>>> preferably
>>> something like a value in sysfs.   However, that should not hold up
>>>     
>>
>> We can do this with ethtool. It can get and print the driver name of
>> the device.
>>   
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
> 

Ben, could you please tell what sysfs features do you
plan to implement?

Thanks,
Pavel
