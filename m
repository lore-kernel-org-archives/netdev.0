From: Joe Jin <joe.jin@oracle.com>
Subject: 82571EB: Detected Hardware Unit Hang
Date: Thu, 08 Nov 2012 14:24:56 +0800
Message-ID: <509B5038.8090304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi list,

IHAC reported "82571EB Detected Hardware Unit Hang" on HP ProLiant DL360 G6, and
have to reboot the server to recover:

e1000e 0000:06:00.1: eth3: Detected Hardware Unit Hang:
  TDH                  <1a>
  TDT                  <1a>
  next_to_use          <1a>
  next_to_clean        <18>
buffer_info[next_to_clean]:
  time_stamp           <10047a74e>
  next_to_watch        <18>
  jiffies              <10047a88c>
  next_to_watch.status <1>
MAC Status             <80383>
PHY Status             <792d>
PHY 1000BASE-T Status  <3800>
PHY Extended Status    <3000>
PCI Status             <10>

With newer kernel 2.0.0.1 the issue still reproducible.

Device info:
06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)
06:00.1 0200: 8086:10bc (rev 06)

I compared lspci output before and after the issue, different as below:
 06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)
 	Subsystem: Hewlett-Packard Company NC364T PCI Express Quad Port Gigabit Server Adapter
 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx-
-	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
+	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+


Would you please help to it?

Thanks in advance,
Joe

-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Senior Manager | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
