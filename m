From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Tue, 25 Sep 2012 16:00:00 +0200
Message-ID: <CAL8zT=i4tdneZVopZGtHVhMArGMH5n=BVrtkaNSVJPX=RtR6OQ@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F3086A3@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
 <CAL8zT=j9LC5hKtmkzBA-Epa+NhX1YpC9RodJ-C+UunTH_HRVKQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F30910B@SJEXCHMB06.corp.ad.broadcom.com> <CAL8zT=h31Prm2dpyKM8wwg_cb1a8_0yP2ziNzhNFC-3J1M0Khg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64441 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab2IYOAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 10:00:20 -0400
Received: by ieak13 with SMTP id k13so13913113iea.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 07:00:20 -0700 (PDT)
In-Reply-To: <CAL8zT=h31Prm2dpyKM8wwg_cb1a8_0yP2ziNzhNFC-3J1M0Khg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/25 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
>>> -----Original Message-----
>>> From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
>>> Sent: Tuesday, September 25, 2012 2:54 PM
>>> To: Dmitry Kravkov
>>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>>> Subject: Re: bnx2x: link detected up at startup even when it should be down
>>
>>
>>> After a reboot (with the added if but no netif_msg) :
>>
>> I'm looking for link messages during device load.
>> These (get_setting/set_settings) appear at the later stages.
>> Will you able to load driver with module param debug=0x4 instead? So we can catch all link related messages
>> (This can be done via /etc/modprobe.conf)
>>
>
> Sorry, you said after a reboot, so I used ethtool, I tried to set
> bnx2x.debug=4 in cmdline but does not seem to work...
> Looking at it...

Here is what I get when starting with cmdline and bnx2x.debug=4 :

[    0.000000] Command line: initrd=initrd_Diskless_full.img rw
root=/dev/ram0 ip=dhcp bnx2x.poll=1 bnx2x.debug=4 BOOT_IMAGE=vmlinuz
BOOTIF=01-80-c1-6e-7a-49-48
[    0.000000] Kernel command line: initrd=initrd_Diskless_full.img rw
root=/dev/ram0 ip=dhcp bnx2x.poll=1 bnx2x.debug=4 BOOT_IMAGE=vmlinuz
BOOTIF=01-80-c1-6e-7a-49-48
[   18.858801] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit
Ethernet Driver bnx2x 1.70.30-1 (2012/08/17)
[   18.858875] bnx2x 0000:04:00.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
[   18.858884] bnx2x 0000:04:00.0: setting latency timer to 64
[   18.859838] bnx2x 0000:04:00.0: part number
394D4342-31383735-31543030-47303030
[   18.860409] bnx2x 0000:04:00.0: irq 90 for MSI/MSI-X
[   18.860418] bnx2x 0000:04:00.0: irq 91 for MSI/MSI-X
[   18.860732] bnx2x 0000:04:00.0: eth0: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
ea000000, IRQ 32, node addr 80:c1:6e:7a:49:48
[   18.861031] bnx2x 0000:04:00.1: PCI INT B -> GSI 36 (level, low) -> IRQ 36
[   18.861035] bnx2x 0000:04:00.1: setting latency timer to 64
[   18.861968] bnx2x 0000:04:00.1: part number
394D4342-31383735-31543030-47303030
[   18.862540] bnx2x 0000:04:00.1: irq 92 for MSI/MSI-X
[   18.862548] bnx2x 0000:04:00.1: irq 93 for MSI/MSI-X
[   18.862816] bnx2x 0000:04:00.1: eth1: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e8800000, IRQ 36, node addr 80:c1:6e:7a:49:4c
[   18.862848] bnx2x 0000:04:00.2: PCI INT B -> GSI 36 (level, low) -> IRQ 36
[   18.862852] bnx2x 0000:04:00.2: setting latency timer to 64
[   18.863784] bnx2x 0000:04:00.2: part number
394D4342-31383735-31543030-47303030
[   18.864347] bnx2x 0000:04:00.2: irq 94 for MSI/MSI-X
[   18.864355] bnx2x 0000:04:00.2: irq 95 for MSI/MSI-X
[   18.864628] bnx2x 0000:04:00.2: eth2: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e7000000, IRQ 36, node addr 80:c1:6e:7a:49:49
[   18.864662] bnx2x 0000:04:00.3: PCI INT C -> GSI 37 (level, low) -> IRQ 37
[   18.864666] bnx2x 0000:04:00.3: setting latency timer to 64
[   18.865598] bnx2x 0000:04:00.3: part number
394D4342-31383735-31543030-47303030
[   18.866360] bnx2x 0000:04:00.3: irq 96 for MSI/MSI-X
[   18.866369] bnx2x 0000:04:00.3: irq 97 for MSI/MSI-X
[   18.866646] bnx2x 0000:04:00.3: eth3: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e5800000, IRQ 37, node addr 80:c1:6e:7a:49:4d
[   18.866677] bnx2x 0000:04:00.4: PCI INT C -> GSI 37 (level, low) -> IRQ 37
[   18.866682] bnx2x 0000:04:00.4: setting latency timer to 64
[   18.867615] bnx2x 0000:04:00.4: part number
394D4342-31383735-31543030-47303030
[   18.868177] bnx2x 0000:04:00.4: irq 98 for MSI/MSI-X
[   18.868185] bnx2x 0000:04:00.4: irq 99 for MSI/MSI-X
[   18.868458] bnx2x 0000:04:00.4: eth4: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e4000000, IRQ 37, node addr 80:c1:6e:7a:49:4a
[   18.868492] bnx2x 0000:04:00.5: PCI INT D -> GSI 38 (level, low) -> IRQ 38
[   18.868496] bnx2x 0000:04:00.5: setting latency timer to 64
[   18.869431] bnx2x 0000:04:00.5: part number
394D4342-31383735-31543030-47303030
[   18.870187] bnx2x 0000:04:00.5: irq 100 for MSI/MSI-X
[   18.870196] bnx2x 0000:04:00.5: irq 101 for MSI/MSI-X
[   18.870474] bnx2x 0000:04:00.5: eth5: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e2800000, IRQ 38, node addr 80:c1:6e:7a:49:4e
[   18.870500] bnx2x 0000:04:00.6: PCI INT D -> GSI 38 (level, low) -> IRQ 38
[   18.870504] bnx2x 0000:04:00.6: setting latency timer to 64
[   18.871436] bnx2x 0000:04:00.6: part number
394D4342-31383735-31543030-47303030
[   18.872188] bnx2x 0000:04:00.6: irq 102 for MSI/MSI-X
[   18.872197] bnx2x 0000:04:00.6: irq 103 for MSI/MSI-X
[   18.872499] bnx2x 0000:04:00.6: eth6: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
e1000000, IRQ 38, node addr 80:c1:6e:7a:49:4b
[   18.872527] bnx2x 0000:04:00.7: PCI INT A -> GSI 32 (level, low) -> IRQ 32
[   18.872530] bnx2x 0000:04:00.7: setting latency timer to 64
[   18.873465] bnx2x 0000:04:00.7: part number
394D4342-31383735-31543030-47303030
[   18.874227] bnx2x 0000:04:00.7: irq 104 for MSI/MSI-X
[   18.874236] bnx2x 0000:04:00.7: irq 105 for MSI/MSI-X
[   18.874514] bnx2x 0000:04:00.7: eth7: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
df800000, IRQ 32, node addr 80:c1:6e:7a:49:4f
[   18.874550] bnx2x 0000:05:00.0: PCI INT A -> GSI 40 (level, low) -> IRQ 40
[   18.874554] bnx2x 0000:05:00.0: setting latency timer to 64
[   18.875488] bnx2x 0000:05:00.0: part number 0-0-0-0
[   18.876060] bnx2x 0000:05:00.0: irq 106 for MSI/MSI-X
[   18.876073] bnx2x 0000:05:00.0: irq 107 for MSI/MSI-X
[   18.876344] bnx2x 0000:05:00.0: eth8: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
f6000000, IRQ 40, node addr 2c:76:8a:59:b3:90
[   18.876377] bnx2x 0000:05:00.1: PCI INT B -> GSI 44 (level, low) -> IRQ 44
[   18.876381] bnx2x 0000:05:00.1: setting latency timer to 64
[   18.877314] bnx2x 0000:05:00.1: part number 0-0-0-0
[   18.877876] bnx2x 0000:05:00.1: irq 108 for MSI/MSI-X
[   18.877884] bnx2x 0000:05:00.1: irq 109 for MSI/MSI-X
[   18.878155] bnx2x 0000:05:00.1: eth9: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
f4800000, IRQ 44, node addr 2c:76:8a:59:b3:94
[   18.878180] bnx2x 0000:05:00.2: PCI INT B -> GSI 44 (level, low) -> IRQ 44
[   18.878184] bnx2x 0000:05:00.2: setting latency timer to 64
[   18.879121] bnx2x 0000:05:00.2: part number 0-0-0-0
[   18.879682] bnx2x 0000:05:00.2: irq 110 for MSI/MSI-X
[   18.879690] bnx2x 0000:05:00.2: irq 111 for MSI/MSI-X
[   18.879966] bnx2x 0000:05:00.2: eth10: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
f3000000, IRQ 44, node addr 2c:76:8a:59:b3:91
[   18.879991] bnx2x 0000:05:00.3: PCI INT C -> GSI 45 (level, low) -> IRQ 45
[   18.879995] bnx2x 0000:05:00.3: setting latency timer to 64
[   18.880927] bnx2x 0000:05:00.3: part number 0-0-0-0
[   18.881492] bnx2x 0000:05:00.3: irq 112 for MSI/MSI-X
[   18.881500] bnx2x 0000:05:00.3: irq 113 for MSI/MSI-X
[   18.881780] bnx2x 0000:05:00.3: eth11: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
f1800000, IRQ 45, node addr 2c:76:8a:59:b3:95
[   18.881806] bnx2x 0000:05:00.4: PCI INT C -> GSI 45 (level, low) -> IRQ 45
[   18.881810] bnx2x 0000:05:00.4: setting latency timer to 64
[   18.882743] bnx2x 0000:05:00.4: part number 0-0-0-0
[   18.883309] bnx2x 0000:05:00.4: irq 114 for MSI/MSI-X
[   18.883318] bnx2x 0000:05:00.4: irq 115 for MSI/MSI-X
[   18.883592] bnx2x 0000:05:00.4: eth12: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
f0000000, IRQ 45, node addr 2c:76:8a:59:b3:92
[   18.883628] bnx2x 0000:05:00.5: PCI INT D -> GSI 46 (level, low) -> IRQ 46
[   18.883632] bnx2x 0000:05:00.5: setting latency timer to 64
[   18.884796] bnx2x 0000:05:00.5: part number 0-0-0-0
[   18.885488] bnx2x 0000:05:00.5: irq 116 for MSI/MSI-X
[   18.885496] bnx2x 0000:05:00.5: irq 117 for MSI/MSI-X
[   18.885784] bnx2x 0000:05:00.5: eth13: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
ee800000, IRQ 46, node addr 2c:76:8a:59:b3:96
[   18.885809] bnx2x 0000:05:00.6: PCI INT D -> GSI 46 (level, low) -> IRQ 46
[   18.885813] bnx2x 0000:05:00.6: setting latency timer to 64
[   18.886747] bnx2x 0000:05:00.6: part number 0-0-0-0
[   18.887440] bnx2x 0000:05:00.6: irq 118 for MSI/MSI-X
[   18.887448] bnx2x 0000:05:00.6: irq 119 for MSI/MSI-X
[   18.887736] bnx2x 0000:05:00.6: eth14: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
ed000000, IRQ 46, node addr 2c:76:8a:59:b3:93
[   18.887761] bnx2x 0000:05:00.7: PCI INT A -> GSI 40 (level, low) -> IRQ 40
[   18.887765] bnx2x 0000:05:00.7: setting latency timer to 64
[   18.888701] bnx2x 0000:05:00.7: part number 0-0-0-0
[   18.889269] bnx2x 0000:05:00.7: irq 124 for MSI/MSI-X
[   18.889278] bnx2x 0000:05:00.7: irq 125 for MSI/MSI-X
[   18.889558] bnx2x 0000:05:00.7: eth15: Broadcom NetXtreme II
BCM57810 10 Gigabit Ethernet (B0) PCI-E x8 5GHz (Gen2) found at mem
eb800000, IRQ 40, node addr 2c:76:8a:59:b3:97
[   26.315404] bnx2x 0000:04:00.0: eth0: using MSI-X  IRQs: sp 90
fp[0] 91 ... fp[0] 91
[   26.767893] bnx2x 0000:04:00.0: eth0: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[   26.902940] bnx2x 0000:05:00.0: eth8: using MSI-X  IRQs: sp 106
fp[0] 107 ... fp[0] 107
[   27.497395] bnx2x 0000:05:00.0: eth8: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  107.683651] bnx2x 0000:04:00.1: eth1: using MSI-X  IRQs: sp 92
fp[0] 93 ... fp[0] 93
[  108.138200] bnx2x 0000:04:00.1: eth1: NIC Link is Up, 8000 Mbps
full duplex, Flow control: ON - receive & transmit
[  108.267249] bnx2x 0000:05:00.1: eth9: using MSI-X  IRQs: sp 108
fp[0] 109 ... fp[0] 109
[  108.546115] bnx2x 0000:04:00.2: eth2: using MSI-X  IRQs: sp 94
fp[0] 95 ... fp[0] 95
[  108.563938] bnx2x 0000:04:00.2: eth2: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  108.715802] bnx2x 0000:05:00.1: eth9: NIC Link is Up, 8000 Mbps
full duplex, Flow control: ON - receive & transmit
[  108.717056] bnx2x 0000:05:00.2: eth10: using MSI-X  IRQs: sp 110
fp[0] 111 ... fp[0] 111
[  108.742813] bnx2x 0000:05:00.2: eth10: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  108.967781] bnx2x 0000:04:00.3: eth3: using MSI-X  IRQs: sp 96
fp[0] 97 ... fp[0] 97
[  108.985640] bnx2x 0000:04:00.3: eth3: NIC Link is Up, 1000 Mbps
full duplex, Flow control: ON - receive & transmit
[  109.138763] bnx2x 0000:05:00.3: eth11: using MSI-X  IRQs: sp 112
fp[0] 113 ... fp[0] 113
[  109.156525] bnx2x 0000:05:00.3: eth11: NIC Link is Up, 1000 Mbps
full duplex, Flow control: ON - receive & transmit
[  109.301397] bnx2x 0000:05:00.3: eth11: NIC Link is Down
[  109.378543] bnx2x 0000:04:00.4: eth4: using MSI-X  IRQs: sp 98
fp[0] 99 ... fp[0] 99
[  109.396368] bnx2x 0000:04:00.4: eth4: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  109.553369] bnx2x 0000:05:00.4: eth12: using MSI-X  IRQs: sp 114
fp[0] 115 ... fp[0] 115
[  109.571232] bnx2x 0000:05:00.4: eth12: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  109.795207] bnx2x 0000:04:00.5: eth5: using MSI-X  IRQs: sp 100
fp[0] 101 ... fp[0] 101
[  109.813079] bnx2x 0000:04:00.5: eth5: NIC Link is Up, 1000 Mbps
full duplex, Flow control: ON - receive & transmit
[  109.966199] bnx2x 0000:05:00.5: eth13: using MSI-X  IRQs: sp 116
fp[0] 117 ... fp[0] 117
[  109.983964] bnx2x 0000:05:00.5: eth13: NIC Link is Up, 1000 Mbps
full duplex, Flow control: ON - receive & transmit
[  110.205039] bnx2x 0000:04:00.6: eth6: using MSI-X  IRQs: sp 102
fp[0] 103 ... fp[0] 103
[  110.222802] bnx2x 0000:04:00.6: eth6: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  110.375810] bnx2x 0000:05:00.6: eth14: using MSI-X  IRQs: sp 118
fp[0] 119 ... fp[0] 119
[  110.393678] bnx2x 0000:05:00.6: eth14: NIC Link is Up, 2500 Mbps
full duplex, Flow control: ON - receive & transmit
[  110.614756] bnx2x 0000:04:00.7: eth7: using MSI-X  IRQs: sp 104
fp[0] 105 ... fp[0] 105
[  110.632521] bnx2x 0000:04:00.7: eth7: NIC Link is Up, 10000 Mbps
full duplex, Flow control: ON - receive & transmit
[  110.785633] bnx2x 0000:05:00.7: eth15: using MSI-X  IRQs: sp 124
fp[0] 125 ... fp[0] 125
[  110.803399] bnx2x 0000:05:00.7: eth15: NIC Link is Up, 10000 Mbps
full duplex, Flow control: ON - receive & transmit
[  111.632943] bnx2x 0000:04:00.1: eth1: using MSI-X  IRQs: sp 92
fp[0] 93 ... fp[0] 93
[  111.651829] bnx2x 0000:04:00.1: eth1: NIC Link is Up, 8000 Mbps
full duplex, Flow control: ON - receive & transmit
[  111.859779] bnx2x 0000:05:00.1: eth9: using MSI-X  IRQs: sp 108
fp[0] 109 ... fp[0] 109
[  111.877664] bnx2x 0000:05:00.1: eth9: NIC Link is Up, 8000 Mbps
full duplex, Flow control: ON - receive & transmit

FYI, eth4 and eth5 are seen UP and they should be down.
JM
