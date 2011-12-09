From: Ben Greear <greearb@candelatech.com>
Subject: Re: Testing server performance
Date: Fri, 09 Dec 2011 09:18:23 -0800
Message-ID: <4EE242DF.2000609@candelatech.com>
References: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56897 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab1LIRS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 12:18:29 -0500
In-Reply-To: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2011 07:26 AM, Igor Maravi=C4=87 wrote:
> Hi all,
> I'm currently testing how much traffic can I push through my server.
> I'm running on Ubuntu 11.10 server with net-next kernel.
> I'm using 2 Gbps NICs, Netgear GA311 and D-Link DGE-528T, that use r8=
169 driver.
> I'm generating UDP packets from a router with constant speed.
>
> After I push traffic to my server with max speed, it saturates.
> It receives packets at 77MBps and it sends packet with 14MBps.
> When there are no incoming traffic, but there are remaining packets i=
n
> tx fifo queue, it sends them with 40MBps.
>
> That all wouldn't be strange because my machine isn't any thing speci=
al
> (AMD Athlon(tm) II X2 240 on 2,8GHz, motherboard ASUS M2N68 PLUS and
> 2x2GB DDR2 RAM memory on 1066MHz),
> but the dstat shows that CPUs are maximally using 6% of their
> resources for interrupt handling.
> Beside that, nothing else is using CPU time.
> Why does it saturate on this values then? Am I doing something wrong?
> Any help is appreciated.

Check the bus speed and width on your NICs.  dmesg usually shows this
info when the interfaces are first detected.

If you can, try some Intel NICs..they will usually run wire speed
if the motherboard is reasonably fast.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
