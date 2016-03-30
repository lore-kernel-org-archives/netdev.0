From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Wed, 30 Mar 2016 11:03:55 +0530
Message-ID: <56FB6543.9060904@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com>
 <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37777 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbcC3FeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 01:34:07 -0400
In-Reply-To: <56FA78AA.4030402@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 March 2016 06:14 PM, Grygorii Strashko wrote:
> On 03/29/2016 03:35 PM, Yegor Yefremov wrote:
>> On Tue, Mar 29, 2016 at 1:05 PM, Grygorii Strashko
>> <grygorii.strashko@ti.com> wrote:
>>> On 03/29/2016 08:21 AM, Yegor Yefremov wrote:
>>>> Hi Mugunthan,
>>>>
>>>> On Tue, Mar 29, 2016 at 6:00 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>>>>> Hi Yegor
>>>>>
>>>>> On Wednesday 16 March 2016 08:35 PM, Yegor Yefremov wrote:
>>>>>> I have an am335x based board using CPSW in Dual EMAC mode. Without
>>>>>> VLAN IDs I can receive and send multicast packets [1]. When I create
>>>>>> VLAN ID:
>>>>>>
>>>>>> ip link add link eth1 name eth1.100 type vlan id 100
>>>>>> ip addr add 192.168.100.2/24 brd 192.168.100.255 dev eth1.100
>>>>>> route add -net 224.0.0.0 netmask 224.0.0.0 eth1.100
>>>>>>
>>>>>> I can successfully send multicast packets, but not receive them. On
>>>>>> the other side of the Ethernet cable I've used Pandaboard. Pandaboard
>>>>>> could both receive and send multicast packets via VLAN.
>>>>>
>>>>> Are you trying multicast tx/rx on eth1 or eth1.100?
>>>>
>>>> I'm trying multicast tx/rx on eth1.100.
>>>>
>>>> eth1 has no problems.
>>>>
>>>
>>> it'd be nice if will be able to post here output fom commands:
>>> # switch-config -d [git://git.ti.com/switch-config/switch-config.git v4.1]
>>> # ifconfig -a
>>> # tcpdump -e -f -Q in -i eth0
>>> # tcpdump -e -f -Q in -i eth0.100
>>
>> Which kernel/branch do you want me to test?
>>
>> git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git and ti-rt-linux-4.1.y?
>>
>> So far I was using vanilla kernel.
> 
> Your branch (but better 4.5 kernels (or 4.4)). 
> Just when you've done with configuration run cmds 1&2,
> and when you run your use-case - run cmds 2&3 on receiver side (grap ~5-10 packets).
> then stop test and run cmd 1 again.
> 
> After all could you provide your console output here, pls.
> 
> 

To use command 1, you need TI kernel [1] as it won't build with vanilla
kernel.

[1]: git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git ti-linux-4.1.y

Regards
Mugunthan V N
