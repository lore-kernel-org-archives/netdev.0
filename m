From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Tue, 29 Mar 2016 09:30:16 +0530
Message-ID: <56F9FDD0.8030504@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <grygorii.strashko@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:39762 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbcC2EAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 00:00:24 -0400
In-Reply-To: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yegor

On Wednesday 16 March 2016 08:35 PM, Yegor Yefremov wrote:
> I have an am335x based board using CPSW in Dual EMAC mode. Without
> VLAN IDs I can receive and send multicast packets [1]. When I create
> VLAN ID:
> 
> ip link add link eth1 name eth1.100 type vlan id 100
> ip addr add 192.168.100.2/24 brd 192.168.100.255 dev eth1.100
> route add -net 224.0.0.0 netmask 224.0.0.0 eth1.100
> 
> I can successfully send multicast packets, but not receive them. On
> the other side of the Ethernet cable I've used Pandaboard. Pandaboard
> could both receive and send multicast packets via VLAN.

Are you trying multicast tx/rx on eth1 or eth1.100?

> 
> This setup was tested with both 3.18.21 and 4.5 kernels.
> 
> Any idea?
> 
> [1] https://pymotw.com/2/socket/multicast.html
> 
