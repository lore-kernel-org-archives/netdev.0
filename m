From: Juergen Kreileder <jk@blackdown.de>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 23:20:30 +0200
Message-ID: <87k67glrvl.fsf@blackdown.de>
References: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.blackdown.de ([213.239.206.42]:57558 "EHLO
	smtp.blackdown.de") by vger.kernel.org with ESMTP id S1751449AbWFPVUf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 17:20:35 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
	(Michael Chan's message of "Fri, 16 Jun 2006 10:02:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> writes:

> Juergen Kreileder
>
>> I'm seeing frequent network timeouts on my PowerMac G5 Quad with
>> 2.6.17-rc6.  The timeouts are easily reproducible with moderate
>> network traffic, e.g. by using bittorrent.
>>
>
> Did this use to work with an older kernel or older tg3 driver? If
> yes, what version?

Works fine with 2.6.16 and earlier.

> Please also provide the full tg3 probing output during modprobe and
> ifconfig up. Thanks.

,----
| tg3.c:v3.58 (May 22, 2006)
| eth0: Tigon3 [partno(BCM95780) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:14:51:66:ff:b2
| eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] 
| eth0: dma_rwctrl[76144000] dma_mask[40-bit]
| eth1: Tigon3 [partno(BCM95780) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:14:51:66:ff:b3
| eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] 
| eth1: dma_rwctrl[76144000] dma_mask[40-bit]
| [...]
| tg3: lan0: Link is up at 1000 Mbps, full duplex.
| tg3: lan0: Flow control is on for TX and on for RX.
`----

eth0 and eth1 get renamed to lan0 and lan1 by udev.  eth0/lan0 is
connected to a Gigabit switch eth1/lan1 is not connected.
Both interface are controlled by ifplugd (using SIOCETHTOOL for link
beat detection).

Let me know if you need more debugging output.


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://blog.blackdown.de/
