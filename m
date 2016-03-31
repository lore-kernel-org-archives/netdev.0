From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Thu, 31 Mar 2016 15:32:35 +0530
Message-ID: <56FCF5BB.2030000@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com>
 <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com>
 <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
 <56FC0431.5000106@ti.com> <878u0z9297.fsf@dell.be.48ers.dk>
 <56FCC59B.70209@ti.com>
 <CAGm1_kutVn+jNf58QwKyO8j5NmRhaOCUsXmpTiLbX75AczCm6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Peter Korsgaard <peter@korsgaard.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:49690 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbcCaKCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 06:02:47 -0400
In-Reply-To: <CAGm1_kutVn+jNf58QwKyO8j5NmRhaOCUsXmpTiLbX75AczCm6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 March 2016 01:22 PM, Yegor Yefremov wrote:
> On Thu, Mar 31, 2016 at 8:37 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>> On Thursday 31 March 2016 01:17 AM, Peter Korsgaard wrote:
>>>>>>>> "Mugunthan" == Mugunthan V N <mugunthanvnm@ti.com> writes:
>>>
>>> Hi,
>>>
>>>  > You had received these packets as tcpdump will enable promiscuous mode
>>>  > so that you receive all the packets from the wire.
>>>
>>> FYI, you can use the -p option to tcpdump to not put the interface into
>>> promiscuous mode.
>>>
>>
>> Thanks for the information Peter Korsgaard.
>>
>> Yegor, can you provide tcpdump using -p as well in Grygorii commands.
> 
> Before VLAN configuration:
> 
> # switch-config -d
> cpsw hw version 1.12 (0)
> 0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
> unreg_mcast = 0x0, member_list = 0x3
> 1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x3
> 2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
> persistant, port_num = 0x0, Secure
> 3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
> unreg_mcast = 0x0, member_list = 0x7
> 4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x3
> 5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
> unreg_mcast = 0x0, member_list = 0x5
> 6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x5
> 7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0, Secure
> 8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x5
> 
> After VLAN configuration:
> 
> # switch-config -d
> cpsw hw version 1.12 (0)
> 0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
> unreg_mcast = 0x0, member_list = 0x3
> 1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x3
> 2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
> persistant, port_num = 0x0, Secure
> 3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
> unreg_mcast = 0x0, member_list = 0x7
> 4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x3
> 5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
> unreg_mcast = 0x0, member_list = 0x5
> 6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x5
> 7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0, Secure
> 8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x5
> 9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
> unreg_mcast = 0x0, member_list = 0x5
> 10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0
> 11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
> f, no super, port_mask = 0x5
> 12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
> no super, port_mask = 0x5
> 
> During mulitcast receive:
> 
> # switch-config -d
> cpsw hw version 1.12 (0)
> 0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
> unreg_mcast = 0x0, member_list = 0x3
> 1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x3
> 2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
> persistant, port_num = 0x0, Secure
> 3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
> unreg_mcast = 0x0, member_list = 0x7
> 4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x3
> 5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
> unreg_mcast = 0x0, member_list = 0x5
> 6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x5
> 7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0, Secure
> 8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x5
> 9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
> unreg_mcast = 0x0, member_list = 0x5
> 10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0
> 11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
> f, no super, port_mask = 0x5
> 12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
> no super, port_mask = 0x5
> 13  : type: mcast, vid = 2, addr = 01:00:5e:03:1d:47, mcast_state = f,
> no super, port_mask = 0x5
> 14  : type: ucast, vid = 100, addr = 66:22:04:bc:90:26, ucast_type =
> untouched , port_num = 0x2

I could see multicast address 01:00:5e:03:1d:47 is added to ALE table at
index 13, but it is added for VLAN id 2 ie eth1, did you ran the test
for eth1 or eth1.100?

Regards
Mugunthan V N
