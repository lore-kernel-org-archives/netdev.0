From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: RE:  [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Fri, 11 Jan 2008 10:24:56 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C26E765F@zin33exm24.fsl.freescale.net>
References: <FBA61160C48B8D438F3323FEFB4EF2C259F2F6@zin33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Phillips Kim" <Kim.Phillips@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>
To: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>,
	<sfr@canb.auug.org.au>, <rubini@vision.unipv.it>,
	<linux-ppcdev@ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:56667 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756852AbYAKEzJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 23:55:09 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hello  All

I am waiting for more feedback on the patches.

If there are no objections please consider them for 2.6.25.

With Regards
Poonam 
 
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Aggrwal Poonam
Sent: Monday, December 10, 2007 5:23 PM
To: rubini@vision.unipv.it; linux-ppcdev@ozlabs.kernel.org;
netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Gala Kumar
Cc: Barkowski Michael; Phillips Kim; Kalra Ashish; Cutler Richard
Subject: [PATCH 0/3] UCC TDM driver for MPC83xx platforms 

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
 
 
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
