From: Patrick McHardy <kaber@trash.net>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 22:43:50 +0200
Message-ID: <4676EE86.5010205@trash.net>
References: <4676E1DD.1060007@trash.net>	<20070618130414.35801913@localhost.localdomain>	<4676E77E.4080707@trash.net> <20070618132021.64b08836@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800060003090509080006"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42108 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764337AbXFRUnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:43:53 -0400
In-Reply-To: <20070618132021.64b08836@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800060003090509080006
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> On Mon, 18 Jun 2007 22:13:50 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>>Does this fix it?  It was possible for the PHY interrupt to race
>>>while bringing link up.
>>
>>
>>No, both problems are still present.
> 
> 
> What hardware. Could you load with messages max: modprobe sky2 debug=15

sky2 0000:05:00.0: v1.14 addr 0xdb000000 irq 36 Yukon-EC (0xb6) rev 2

Unloading the driver (with your patch) crashed my box twice. I've
attached a log of loading the driver with debug=15, transmitting
a few packets, then setting it down and up again and trying to
transmit a few more packets (which didn't work).


--------------010800060003090509080006
Content-Type: text/plain;
 name="sky2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sky2"

ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 36 (level, low) -> IRQ 36
PCI: Setting latency timer of device 0000:05:00.0 to 64
sky2 0000:05:00.0: v1.14 addr 0xdb000000 irq 36 Yukon-EC (0xb6) rev 2
APIC error on CPU0: 08(08)
APIC error on CPU1: 08(08)
sky2 0000:05:00.0: No interrupt generated using MSI, switching to INTx mode.
sky2 eth0: addr 00:15:f2:24:91:f8
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
ADDRCONF(NETDEV_UP): eth0: link is not ready
sky2 eth0: phy interrupt status 0x1c00 0x7d0c
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: tx queued, slot 0, len 90
eth0: tx done 1
sky2 eth0: rx slot 0 status 0xdb0300 len 219
sky2 eth0: rx slot 1 status 0xdc2300 len 220
sky2 eth0: rx slot 2 status 0xdc2300 len 220
sky2 eth0: rx slot 3 status 0xdc2300 len 220
sky2 eth0: rx slot 4 status 0xdc2300 len 220
sky2 eth0: rx slot 5 status 0xdc2300 len 220
sky2 eth0: rx slot 6 status 0xdc2300 len 220
sky2 eth0: rx slot 7 status 0xdc2300 len 220
sky2 eth0: rx slot 8 status 0xdc2300 len 220
sky2 eth0: rx slot 9 status 0xdc2300 len 220
sky2 eth0: rx slot 10 status 0xdc2300 len 220
eth0: tx queued, slot 2, len 42
sky2 eth0: rx slot 11 status 0x3c0100 len 60
eth0: tx queued, slot 3, len 81
eth0: tx queued, slot 5, len 71
eth0: tx done 2
sky2 eth0: rx slot 12 status 0x980100 len 152
eth0: tx done 4
eth0: tx done 5
sky2 eth0: rx slot 13 status 0xad0100 len 173
eth0: tx queued, slot 6, len 98
sky2 eth0: rx slot 14 status 0x620100 len 98
eth0: tx done 6
eth0: tx queued, slot 7, len 81
eth0: tx queued, slot 8, len 84
sky2 eth0: rx slot 15 status 0x1410100 len 321
eth0: tx done 7
eth0: tx queued, slot 9, len 81
eth0: tx done 8
sky2 eth0: rx slot 16 status 0xd30100 len 211
eth0: tx done 9
sky2 eth0: rx slot 17 status 0x1410100 len 321
eth0: tx queued, slot 10, len 81
sky2 eth0: rx slot 18 status 0x980100 len 152
eth0: tx done 10
eth0: tx queued, slot 11, len 81
sky2 eth0: rx slot 19 status 0x1410100 len 321
eth0: tx done 11
eth0: tx queued, slot 12, len 81
sky2 eth0: rx slot 20 status 0x1410100 len 321
eth0: tx done 12
eth0: tx queued, slot 13, len 81
sky2 eth0: rx slot 21 status 0x980100 len 152
eth0: tx done 13
eth0: tx queued, slot 14, len 81
sky2 eth0: rx slot 22 status 0x1410100 len 321
eth0: tx done 14
eth0: tx queued, slot 15, len 81
sky2 eth0: rx slot 23 status 0x1410100 len 321
eth0: tx done 15
eth0: tx queued, slot 16, len 81
sky2 eth0: rx slot 24 status 0x980100 len 152
eth0: tx done 16
eth0: tx queued, slot 17, len 81
sky2 eth0: rx slot 25 status 0x1410100 len 321
eth0: tx done 17
eth0: tx queued, slot 18, len 81
sky2 eth0: rx slot 26 status 0x1410100 len 321
eth0: tx done 18
eth0: tx queued, slot 19, len 90
eth0: tx done 19
eth0: tx queued, slot 20, len 90
eth0: tx done 20
sky2 eth0: rx slot 27 status 0x5a0100 len 90
eth0: tx queued, slot 21, len 90
eth0: tx done 21
eth0: tx queued, slot 22, len 90
eth0: tx done 22
eth0: tx queued, slot 23, len 78
eth0: tx done 23
sky2 eth0: rx slot 28 status 0x5a0100 len 90
eth0: tx queued, slot 24, len 90
eth0: tx done 24
sky2 eth0: rx slot 29 status 0x5a0100 len 90
eth0: tx queued, slot 25, len 90
eth0: tx done 25
sky2 eth0: rx slot 30 status 0x5a0100 len 90
eth0: tx queued, slot 26, len 90
eth0: tx done 26
sky2 eth0: rx slot 31 status 0x5a0100 len 90
eth0: tx queued, slot 27, len 90
eth0: tx done 27
eth0: tx queued, slot 28, len 90
eth0: tx done 28
sky2 eth0: rx slot 32 status 0x5a0100 len 90
sky2 eth0: rx slot 33 status 0x5a0100 len 90
eth0: tx queued, slot 29, len 90
eth0: tx done 29
sky2 eth0: rx slot 34 status 0x5a0100 len 90
eth0: tx queued, slot 30, len 90
eth0: tx done 30
eth0: tx queued, slot 31, len 90
eth0: tx done 31
sky2 eth0: rx slot 35 status 0x5a0100 len 90
eth0: tx queued, slot 32, len 90
eth0: tx done 32
sky2 eth0: rx slot 36 status 0x5a0100 len 90
eth0: tx queued, slot 33, len 90
eth0: tx done 33
sky2 eth0: rx slot 37 status 0x5a0100 len 90
sky2 eth0: rx slot 38 status 0xce0300 len 206
sky2 eth0: rx slot 39 status 0xcf2300 len 207
sky2 eth0: rx slot 40 status 0xcf2300 len 207
sky2 eth0: rx slot 41 status 0xcf2300 len 207
sky2 eth0: rx slot 42 status 0xcf2300 len 207
sky2 eth0: rx slot 43 status 0xcf2300 len 207
sky2 eth0: rx slot 44 status 0xcf2300 len 207
sky2 eth0: rx slot 45 status 0xcf2300 len 207
sky2 eth0: rx slot 46 status 0xcf2300 len 207
sky2 eth0: rx slot 47 status 0xcf2300 len 207
sky2 eth0: rx slot 48 status 0xcf2300 len 207
sky2 eth0: rx slot 49 status 0x5a0100 len 90
eth0: tx queued, slot 34, len 90
eth0: tx done 34
sky2 eth0: rx slot 50 status 0x5a0100 len 90
eth0: tx queued, slot 35, len 90
eth0: tx done 35
sky2 eth0: rx slot 51 status 0x5a0100 len 90
eth0: tx queued, slot 36, len 90
eth0: tx done 36
eth0: tx queued, slot 37, len 90
eth0: tx done 37
sky2 eth0: rx slot 52 status 0x5a0100 len 90
sky2 eth0: rx slot 53 status 0x5a0100 len 90
eth0: tx queued, slot 38, len 90
eth0: tx done 38
sky2 eth0: rx slot 54 status 0x5a0100 len 90
sky2 eth0: rx slot 55 status 0x5a0100 len 90
eth0: tx queued, slot 39, len 90
eth0: tx done 39
sky2 eth0: rx slot 56 status 0x5a0100 len 90
eth0: tx queued, slot 40, len 90
eth0: tx done 40
sky2 eth0: rx slot 57 status 0x5a0100 len 90
eth0: tx queued, slot 41, len 90
eth0: tx done 41
sky2 eth0: rx slot 58 status 0x5a0100 len 90
eth0: tx queued, slot 42, len 90
eth0: tx done 42
sky2 eth0: rx slot 59 status 0x5a0100 len 90
eth0: tx queued, slot 43, len 90
eth0: tx done 43
sky2 eth0: rx slot 60 status 0x5a0100 len 90
eth0: tx queued, slot 44, len 90
eth0: tx done 44
sky2 eth0: rx slot 61 status 0x5a0100 len 90
eth0: tx queued, slot 45, len 90
eth0: tx done 45
eth0: tx queued, slot 46, len 70
eth0: tx done 46
sky2 eth0: rx slot 62 status 0x6e0500 len 110
sky2 eth0: rx slot 63 status 0x5a0100 len 90
eth0: tx queued, slot 47, len 90
eth0: tx done 47
eth0: tx queued, slot 48, len 78
eth0: tx done 48
eth0: tx queued, slot 49, len 90
eth0: tx done 49
sky2 eth0: rx slot 64 status 0x5a0100 len 90
eth0: tx queued, slot 50, len 90
eth0: tx done 50
eth0: tx queued, slot 51, len 90
eth0: tx done 51
sky2 eth0: rx slot 65 status 0x5a0100 len 90
eth0: tx queued, slot 52, len 90
eth0: tx done 52
sky2 eth0: rx slot 66 status 0x5a0100 len 90
eth0: tx queued, slot 53, len 90
eth0: tx done 53
eth0: tx queued, slot 54, len 90
eth0: tx done 54
sky2 eth0: rx slot 67 status 0x5a0100 len 90
eth0: tx queued, slot 55, len 90
eth0: tx done 55
sky2 eth0: rx slot 68 status 0x5a0100 len 90
eth0: tx queued, slot 56, len 90
eth0: tx done 56
sky2 eth0: rx slot 69 status 0x5a0100 len 90
eth0: tx queued, slot 57, len 90
eth0: tx done 57
sky2 eth0: rx slot 70 status 0x5a0100 len 90
eth0: tx queued, slot 58, len 90
eth0: tx done 58
sky2 eth0: rx slot 71 status 0x5a0100 len 90
sky2 eth0: rx slot 72 status 0x5a0100 len 90
eth0: tx queued, slot 59, len 90
eth0: tx done 59
sky2 eth0: rx slot 73 status 0x5a0100 len 90
eth0: tx queued, slot 60, len 90
eth0: tx done 60
sky2 eth0: rx slot 74 status 0x5a0100 len 90
eth0: tx queued, slot 61, len 90
eth0: tx done 61
sky2 eth0: rx slot 75 status 0x5a0100 len 90
eth0: tx queued, slot 62, len 90
eth0: tx done 62
sky2 eth0: rx slot 76 status 0x5a0100 len 90
eth0: tx queued, slot 63, len 90
eth0: tx done 63
sky2 eth0: rx slot 77 status 0x5a0100 len 90
eth0: tx queued, slot 64, len 90
eth0: tx done 64
sky2 eth0: rx slot 78 status 0x5a0100 len 90
eth0: tx queued, slot 65, len 90
eth0: tx queued, slot 66, len 90
eth0: tx done 65
eth0: tx done 66
sky2 eth0: rx slot 79 status 0x5a0100 len 90
eth0: tx queued, slot 67, len 90
eth0: tx done 67
sky2 eth0: rx slot 80 status 0x5a0100 len 90
eth0: tx queued, slot 68, len 90
eth0: tx done 68
sky2 eth0: rx slot 81 status 0x5a0100 len 90
sky2 eth0: rx slot 82 status 0x5a0100 len 90
eth0: tx queued, slot 69, len 90
eth0: tx done 69
sky2 eth0: rx slot 83 status 0x5a0100 len 90
sky2 eth0: rx slot 84 status 0x5a0100 len 90
eth0: tx queued, slot 70, len 90
eth0: tx done 70
sky2 eth0: rx slot 85 status 0x5a0100 len 90
eth0: tx queued, slot 71, len 90
eth0: tx done 71
sky2 eth0: rx slot 86 status 0x5a0100 len 90
eth0: tx queued, slot 72, len 90
eth0: tx done 72
sky2 eth0: rx slot 87 status 0x5a0100 len 90
eth0: tx queued, slot 73, len 90
eth0: tx done 73
sky2 eth0: rx slot 88 status 0x5a0100 len 90
eth0: tx queued, slot 74, len 90
eth0: tx done 74
sky2 eth0: rx slot 89 status 0x5a0100 len 90
eth0: tx queued, slot 75, len 90
eth0: tx done 75
sky2 eth0: rx slot 90 status 0x5a0100 len 90
eth0: tx queued, slot 76, len 90
eth0: tx done 76
sky2 eth0: rx slot 91 status 0x5a0100 len 90
eth0: tx queued, slot 77, len 90
eth0: tx done 77
sky2 eth0: rx slot 92 status 0x5a0100 len 90
eth0: tx queued, slot 78, len 90
eth0: tx done 78
sky2 eth0: rx slot 93 status 0x5a0100 len 90
eth0: tx queued, slot 79, len 90
eth0: tx done 79
sky2 eth0: rx slot 94 status 0x5a0100 len 90
eth0: tx queued, slot 80, len 90
eth0: tx done 80
sky2 eth0: rx slot 95 status 0x5a0100 len 90
eth0: tx queued, slot 81, len 90
eth0: tx done 81
sky2 eth0: rx slot 96 status 0x5a0100 len 90
eth0: tx queued, slot 82, len 90
eth0: tx done 82
sky2 eth0: rx slot 97 status 0x5a0100 len 90
eth0: tx queued, slot 83, len 90
eth0: tx done 83
eth0: tx queued, slot 84, len 90
eth0: tx queued, slot 85, len 90
eth0: tx done 84
eth0: tx done 85
sky2 eth0: rx slot 98 status 0x5a0100 len 90
sky2 eth0: rx slot 99 status 0x5a0100 len 90
eth0: tx queued, slot 86, len 90
eth0: tx done 86
sky2 eth0: rx slot 100 status 0x5a0100 len 90
eth0: tx queued, slot 87, len 90
eth0: tx done 87
eth0: tx queued, slot 88, len 90
eth0: tx done 88
sky2 eth0: rx slot 101 status 0x5a0100 len 90
eth0: tx queued, slot 89, len 90
eth0: tx done 89
sky2 eth0: rx slot 102 status 0x5a0100 len 90
eth0: tx queued, slot 90, len 90
eth0: tx done 90
sky2 eth0: rx slot 103 status 0x5a0100 len 90
eth0: tx queued, slot 91, len 90
eth0: tx done 91
sky2 eth0: rx slot 104 status 0x5a0100 len 90
eth0: tx queued, slot 92, len 90
eth0: tx done 92
sky2 eth0: rx slot 105 status 0x5a0100 len 90
eth0: tx queued, slot 93, len 90
eth0: tx done 93
sky2 eth0: rx slot 106 status 0x5a0100 len 90
eth0: tx queued, slot 94, len 90
eth0: tx done 94
sky2 eth0: rx slot 107 status 0x5a0100 len 90
eth0: tx queued, slot 95, len 90
eth0: tx done 95
sky2 eth0: rx slot 108 status 0x5a0100 len 90
eth0: tx queued, slot 96, len 90
sky2 eth0: rx slot 109 status 0x5a0100 len 90
eth0: tx done 96
eth0: tx queued, slot 97, len 90
eth0: tx done 97
sky2 eth0: rx slot 110 status 0x5a0100 len 90
sky2 eth0: rx slot 111 status 0x5a0100 len 90
eth0: tx queued, slot 98, len 90
eth0: tx done 98
sky2 eth0: rx slot 112 status 0x5a0100 len 90
eth0: tx queued, slot 99, len 90
eth0: tx done 99
sky2 eth0: rx slot 113 status 0x5a0100 len 90
sky2 eth0: rx slot 114 status 0x5a0100 len 90
eth0: tx queued, slot 100, len 90
eth0: tx done 100
sky2 eth0: rx slot 115 status 0x5a0100 len 90
eth0: tx queued, slot 101, len 90
eth0: tx done 101
sky2 eth0: rx slot 116 status 0x5a0100 len 90
eth0: tx queued, slot 102, len 90
eth0: tx done 102
eth0: tx queued, slot 103, len 90
eth0: tx done 103
sky2 eth0: rx slot 117 status 0x5a0100 len 90
sky2 eth0: rx slot 118 status 0x5a0100 len 90
eth0: tx queued, slot 104, len 90
eth0: tx done 104
sky2 eth0: rx slot 119 status 0x5a0100 len 90
eth0: tx queued, slot 105, len 90
eth0: tx done 105
sky2 eth0: rx slot 120 status 0x5a0100 len 90
eth0: tx queued, slot 106, len 90
eth0: tx done 106
eth0: tx queued, slot 107, len 90
eth0: tx done 107
sky2 eth0: rx slot 121 status 0x5a0100 len 90
sky2 eth0: rx slot 122 status 0x5a0100 len 90
eth0: tx queued, slot 108, len 90
eth0: tx done 108
sky2 eth0: rx slot 123 status 0x5a0100 len 90
eth0: tx queued, slot 109, len 90
eth0: tx done 109
sky2 eth0: disabling interface
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
ADDRCONF(NETDEV_UP): eth0: link is not ready
sky2 eth0: phy interrupt status 0x1c00 0x7d0c
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: tx queued, slot 0, len 90
eth0: tx done 0
eth0: tx queued, slot 1, len 42
eth0: tx done 1
eth0: tx queued, slot 2, len 78
eth0: tx done 2
eth0: tx queued, slot 3, len 42
eth0: tx done 3
eth0: tx queued, slot 4, len 70
eth0: tx done 4
eth0: tx queued, slot 5, len 90
eth0: tx done 5
eth0: tx queued, slot 6, len 42
eth0: tx done 6
eth0: tx queued, slot 7, len 42
eth0: tx done 7
eth0: tx queued, slot 8, len 42
eth0: tx done 8
eth0: tx queued, slot 9, len 42
eth0: tx done 9
eth0: tx queued, slot 10, len 70
eth0: tx done 10
eth0: tx queued, slot 11, len 42
eth0: tx done 11
eth0: tx queued, slot 12, len 42
eth0: tx done 12
eth0: tx queued, slot 13, len 42
eth0: tx done 13
eth0: tx queued, slot 14, len 70
eth0: tx done 14
eth0: tx queued, slot 15, len 42
eth0: tx done 15
eth0: no IPv6 routers present
eth0: tx queued, slot 16, len 42
eth0: tx done 16
eth0: tx queued, slot 17, len 42
eth0: tx done 17
eth0: tx queued, slot 18, len 42
eth0: tx done 18
eth0: tx queued, slot 19, len 42
eth0: tx done 19
eth0: tx queued, slot 20, len 42
eth0: tx done 20
eth0: tx queued, slot 21, len 42
eth0: tx done 21
sky2 eth0: disabling interface
ACPI: PCI interrupt for device 0000:05:00.0 disabled

--------------010800060003090509080006--
