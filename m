From: David Liontooth <liontooth@cogweb.net>
Subject: Re: ICS1883 LAN PHY not detected
Date: Sat, 02 Apr 2005 21:27:32 -0800
Message-ID: <424F7EC4.1000107@cogweb.net>
References: <424EF19B.7030105@cogweb.net> <424F45F0.1000504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261172AbVDCF2k@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <424F45F0.1000504@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> David Liontooth wrote:
>
>> 0000:02:0b.0 Ethernet controller: Marvell Technology Group Ltd. Yukon 
>> Gigabit Ethernet 10/100/1000Base-T Adapter (rev 13)
>
> You want the sk98lin or skge drivers.

Correct -- that one worked already in Debian-Installer. What was 
confusing is that the Gigabyte K8NS Ultra-939 board has a second 
gigabyte NIC, identified in the motherboard manual as a 100/10 ICS1883 
LAN PHY, that is in fact an nforce gigabyte controller, part of the 
nforce3 250 chipset (cf. 
http://cogweb.net/owens/Images/Gigabyte-K8NS-Ultra-939.jpg line 5). For 
some reason the PCI ID 00E6 doesn't show up in lspci, so I thought it 
was not detected by the kernel. However, the forcedeth driver brought it 
to life.

Dave
