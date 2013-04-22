From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Mon, 22 Apr 2013 22:31:38 +0530
Message-ID: <51756CF2.4050602@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk> <516C3A0D.70903@ti.com> <517018E6.6080108@newflow.co.uk> <51754427.7000908@newflow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Mark Jackson <mpfj-list@newflow.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46630 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322Ab3DVRBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 13:01:53 -0400
In-Reply-To: <51754427.7000908@newflow.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/2013 7:37 PM, Mark Jackson wrote:
> Mugunthan
>
> Can you confirm that I'm actually trying to achieve the right thing ?
>
> I have all along assumed that Dual EMAC mode would simply provide the
> kernel will a pair of independent Ethernet ports.
Yes, it will provide two network interfaces for ex eth0 and eth1
> All I am trying to do is to get both Ethernet ports working so I can
> have one port on (say) 10.0.x.x and the other on (say) 10.1.x.x
This is perfectly correct
> But there is all this reference to VLANs(in the source code and the TRM)
> ... I have not setup any VLANs.  Do I need to ?  If so, how ?
No need to setup any VLAN. VLAN are used to segregate the
two down stream ports and it will be taken care by the driver

Regards
Mugunthan V N
