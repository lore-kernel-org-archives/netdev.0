From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: 3c59x transmit timed out.
Date: Mon, 29 May 2006 11:07:18 +0400
Message-ID: <20060529070718.GA8042@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45282 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750716AbWE2HHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 May 2006 03:07:24 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is part of the dmesg on my 3c59x test machine.
This happend first time and I'm quite sure after module reloading things
will be ok again, so it is not bug report but probably some meat for brain...

Hmm... I can not login using neither serial console, nor direct access,
it looks like something eats 100% cpu, since I can scroll console and
type, but login is frozen.

You can find lspci -vxxx at the end.
Kernel is 2.6.16.

[17422676.004000] eth0: transmit timed out, tx_status 00 status e680.
[17422676.012000]   diagnostics: net 0cfa media 8880 dma 0000003a fifo
8000
[17422676.016000]   Flags; bus-master 1, dirty 35095(7) current 35111(7)
[17422676.024000]   Transmit list 00000000 vs. f6f54660.
[17422676.028000]   0: @f6f54200  length 8000002a status 0001002a
[17422676.036000]   1: @f6f542a0  length 8000002a status 0001002a
[17422676.040000]   2: @f6f54340  length 8000002a status 0001002a
[17422676.048000]   3: @f6f543e0  length 8000002a status 0001002a
[17422676.052000]   4: @f6f54480  length 8000002a status 0001002a
[17422676.060000]   5: @f6f54520  length 8000002a status 8001002a
[17422676.064000]   6: @f6f545c0  length 8000002a status 8001002a
[17422676.072000]   7: @f6f54660  length 80000042 status 00010042
[17422676.076000]   8: @f6f54700  length 8000002a status 0001002a
[17422676.080000]   9: @f6f547a0  length 8000002a status 0001002a
[17422676.088000]   10: @f6f54840  length 8000002a status 0001002a
[17422676.092000]   11: @f6f548e0  length 8000002a status 0001002a
[17422676.100000]   12: @f6f54980  length 8000002a status 0001002a
[17422676.104000]   13: @f6f54a20  length 8000002a status 0001002a
[17422676.112000]   14: @f6f54ac0  length 8000002a status 0001002a
[17422676.116000]   15: @f6f54b60  length 8000002a status 0001002a
[17422686.124000] eth0: transmit timed out, tx_status 00 status e680.
[17422686.132000]   diagnostics: net 0cfa media 8880 dma 0000003a fifo
8000
[17422686.136000]   Flags; bus-master 1, dirty 35095(7) current 35111(7)
[17422686.144000]   Transmit list 00000000 vs. f6f54660.
[17422686.148000]   0: @f6f54200  length 8000002a status 0001002a
[17422686.156000]   1: @f6f542a0  length 8000002a status 0001002a
[17422686.160000]   2: @f6f54340  length 8000002a status 0001002a
[17422686.168000]   3: @f6f543e0  length 8000002a status 0001002a
[17422686.172000]   4: @f6f54480  length 8000002a status 0001002a
[17422686.180000]   5: @f6f54520  length 8000002a status 8001002a
[17422686.184000]   6: @f6f545c0  length 8000002a status 8001002a
[17422686.188000]   7: @f6f54660  length 80000042 status 00010042
[17422686.196000]   8: @f6f54700  length 8000002a status 0001002a
[17422686.200000]   9: @f6f547a0  length 8000002a status 0001002a
[17422686.208000]   10: @f6f54840  length 8000002a status 0001002a
[17422686.212000]   11: @f6f548e0  length 8000002a status 0001002a
[17422686.220000]   12: @f6f54980  length 8000002a status 0001002a
[17422686.224000]   13: @f6f54a20  length 8000002a status 0001002a
[17422686.232000]   14: @f6f54ac0  length 8000002a status 0001002a
[17422686.236000]   15: @f6f54b60  length 8000002a status 0001002a

lspci:

01:00.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
        Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC Management NIC
        Flags: bus master, medium devsel, latency 64, IRQ 17
        I/O ports at cc00 [size=128]
        Memory at fc7ffc00 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at 54000000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
00: b7 10 00 92 17 01 10 02 74 00 00 02 10 40 00 00
10: 01 cc 00 00 00 fc 7f fc 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 b7 10 00 10
30: 00 00 7c fc dc 00 00 00 00 00 00 00 0b 01 0a 0a
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 fe
e0: 00 40 00 b7 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

-- 
	Evgeniy Polyakov
