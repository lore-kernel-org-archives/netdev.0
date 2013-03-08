From: CAI Qian <caiqian@redhat.com>
Subject: be2net failed to initialize regression
Date: Fri, 8 Mar 2013 04:05:30 -0500 (EST)
Message-ID: <1306201826.11289096.1362733530172.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ivan Vecera <ivecera@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emulex CNA card failed to initialize using 3.8 and the latest upstream kernel,

[   87.479859] be2net 0000:04:00.0: POST timeout; stage=0xc911 
[   87.515978] be2net 0000:04:00.0: Emulex OneConnect initialization failed 
[   87.557130] be2net: probe of 0000:04:00.0 failed with error -1 

lspci output,

04:00.0 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (rev 02)
04:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (rev 02)

04:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (rev 02)
        Subsystem: Hewlett-Packard Company NC551i Dual Port FlexFabric 10Gb Adapter

Confirmed no such problem using 3.7 kernel. Reproduced every time and still
bisecting. Just want to give an early head-up to see if anyone saw sometime
obvious.

CAI Qian
