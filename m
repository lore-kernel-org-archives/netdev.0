From: Greg <gvrose8192@gmail.com>
Subject: Re: e1000e on Thinkpad x60: gigabit not available due to
 "SmartSpeed"
Date: Thu, 01 Sep 2016 14:58:13 -0700
Message-ID: <1472767093.3889.4.camel@gmail.com>
References: <20160901201408.GA5061@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901201408.GA5061@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 22:14 +0200, Pavel Machek wrote:
> Hi!
> 
> I have trouble getting 1000mbit out of my ethernet card.
> 
> I tried direct connection between two PCs with different cables, and
> no luck.
> 
> Today I tried connection to 1000mbit switch, and no luck, either. (Two
> cables, one was cat6, both short).
> 
> My computer sees 1000mbit being advertised by the other side, but does
> not advertise 1000mbit, "Link Speed was downgraded by SmartSpeed".

Check your cables?

https://vmxp.wordpress.com/2015/01/06/1gbe-intel-nic-throttled-to-100mbit-by-smartspeed/

- Greg

> 
> 4.8.0-rc4+ kernel.
> 
> Does it work for other people? Card is:
> 
> 02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet
> Controller
> 
> root@duo:/data/l/linux# mii-tool -v eth1
> SIOCGMIIREG on eth1 failed: Input/output error
> SIOCGMIIREG on eth1 failed: Input/output error
> eth1: negotiated 100baseTx-FD, link ok
>   product info: Yukon-EC 88E1111 rev 0
>   basic mode:   autonegotiation enabled
>   basic status: autonegotiation complete, link ok
>   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
>   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
>   link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
> root@duo:/data/l/linux#
> 
> [ 1330.622658] e1000e: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow
> Control: None
> [ 1330.622840] e1000e 0000:02:00.0 eth1: Link Speed was downgraded by
> SmartSpeed
> [ 1330.622846] e1000e 0000:02:00.0 eth1: 10/100 speed: disabling TSO
> root@duo:/data/l/linux#
> 
> Best regards,
> 
> 									Pavel
> 
