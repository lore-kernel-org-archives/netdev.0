From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [BUG 2.6.34-rc1] bogus "(null)" in tulip init messages
Date: Wed, 10 Mar 2010 16:33:28 +0100
Message-ID: <19351.48072.777754.465084@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fanny.its.uu.se ([130.238.4.241]:56304 "EHLO fanny.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756690Ab0CJPdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 10:33:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Booting 2.6.34-rc1 on a machine with a tulip nic I see
a number of kernel messages that include "(null)" where
previous kernels included the string "tulip0":

--- dmesg-2.6.33	2010-02-26 12:58:32.000000000 +0100
+++ dmesg-2.6.34-rc1	2010-03-10 16:17:06.000000000 +0100
...
 Linux Tulip driver version 1.1.15 (Feb 27, 2007)
 tulip 0000:00:0f.0: enabling device (0014 -> 0017)
-tulip0:  EEPROM default media type Autosense.
-tulip0:  Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block.
-tulip0:  Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block.
-tulip0:  Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block.
-tulip0:  Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block.
-tulip0:  Index #4 - Media 100baseTx (#3) described by a 21143 reset method (5) block.
-eth0: Digital DS21142/43 Tulip rev 48 at Port 0x800, 00:00:c5:50:f9:51, IRQ 25.
+ (null): EEPROM default media type Autosense
+ (null): Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block
+ (null): Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block
+ (null): Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block
+ (null): Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block
+ (null): Index #4 - Media 100baseTx (#3) described by a 21143 reset method (5) block
+net eth0: Digital DS21142/43 Tulip rev 48 at Port 0x800, 00:00:c5:50:f9:51, IRQ 25

Apart from this the tulip driver seems to work in 2.6.34-rc1.

/Mikael
