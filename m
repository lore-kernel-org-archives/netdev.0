From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Mon, 10 Dec 2007 17:23:20 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C259F2F6@zin33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Phillips Kim" <Kim.Phillips@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>
To: <rubini@vision.unipv.it>, <linux-ppcdev@ozlabs.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Gala Kumar" <kumar.gala@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:55602 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718AbXLJLx1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 06:53:27 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are three patches
[PATCH 1/3] drivers/misc : UCC TDM driver for mpc83xx platforms. This
driver is usable in VoIP iind of applications to interface with SLIC
kind of devices to exchange TDM voice samples.

[PATCH 2/3] arch/ : Platform changes
- device tree entries for UCC TDM driver for MPC8323ERDB platform.
- QE changes related to TDM , like,
	 1) Modified ucc_fast_init so that it can be used by fast UCC
based TDM driver. Mainly changes have been made to configure TDM clocks
and Fsyncs.

	2) Modified get_brg_clk so that it can return the input frequncy
and input source of any BRG by reading the corresponding entries from
device tree.

	3) Added new nodes brg and clocks in the device tree which
represent input clocks for different BRGs.

	4) Modified qe_setbrg accordingly.
- new device tree entries added for "clocks" and "brg"

[PATCH 3/3] Documentation
- Modified Documentation to explain the device tree entries related to
UCC TDM driver and the new nodes added("clocks" and "brg")

The patch applies over a merge of galak's for-2.6.25 plus for-2.6.24
plus of_doc_update branches.
In brief the steps were
git clone
git://git.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git
powerpc-galak git checkout -b for-2.6.25 origin/for-2.6.25 git checkout
-b for-2.6.24 origin/for-2.6.24 git checkout -b of_doc_update
origin/of_doc_update
git pull . for-2.6.24    # merge the other two
git pull . for-2.6.25 
git checkout -b tdm      # clean slate for tdm rebase work

Also after applying the patches changes have to be made corresponding to
Tabi's patch "qe: add function qe_clock_source".

The driver has been tested with a VoIP stack and application on
MPC8323ERDB.

With Regards
Poonam 
 
 
