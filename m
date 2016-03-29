From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Tue, 29 Mar 2016 14:05:16 +0300
Message-ID: <56FA616C.9080502@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Yegor Yefremov <yegorslists@googlemail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:49453 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbcC2LFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 07:05:25 -0400
In-Reply-To: <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2016 08:21 AM, Yegor Yefremov wrote:
> Hi Mugunthan,
> 
> On Tue, Mar 29, 2016 at 6:00 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>> Hi Yegor
>>
>> On Wednesday 16 March 2016 08:35 PM, Yegor Yefremov wrote:
>>> I have an am335x based board using CPSW in Dual EMAC mode. Without
>>> VLAN IDs I can receive and send multicast packets [1]. When I create
>>> VLAN ID:
>>>
>>> ip link add link eth1 name eth1.100 type vlan id 100
>>> ip addr add 192.168.100.2/24 brd 192.168.100.255 dev eth1.100
>>> route add -net 224.0.0.0 netmask 224.0.0.0 eth1.100
>>>
>>> I can successfully send multicast packets, but not receive them. On
>>> the other side of the Ethernet cable I've used Pandaboard. Pandaboard
>>> could both receive and send multicast packets via VLAN.
>>
>> Are you trying multicast tx/rx on eth1 or eth1.100?
> 
> I'm trying multicast tx/rx on eth1.100.
> 
> eth1 has no problems.
> 

it'd be nice if will be able to post here output fom commands:
# switch-config -d [git://git.ti.com/switch-config/switch-config.git v4.1]
# ifconfig -a
# tcpdump -e -f -Q in -i eth0
# tcpdump -e -f -Q in -i eth0.100


-- 
regards,
-grygorii
