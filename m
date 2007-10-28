From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [RFC][BNX2X] .h files rewrite
Date: Sun, 28 Oct 2007 22:17:50 +0200
Message-ID: <1193602670.4836.25.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Max Asbock" <masbock@us.ibm.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1234 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbXJ1UQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 16:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please take a look and tell me if this is better than the last attempt.

Main changes:

* Rewrite of the init code: 
	1. Full rewrite of the generated code into something easier to read.
	2. Removed zeroes by adding a zero command.
	3. Big chucks of data are read by the chip using the DMA engine (instead of being written by the driver).
	4. Gzipped more of the data.

* Removed BE microcode, the swapping is done in the driver instead.

* Rewrite of the HSI - broke it into three files bnx2x_hsi.h bnx2x_reg.h and bnx2x_fw_defs.h

* Fixed SPARSE warnings.

* Fixed all but three checkpatch.pl warnings. (IMHO they are false positives)

The diff is against latest net-2.6.

ftp link:
ftp://Net_sys_anon@ftp1.broadcom.com/0001-bnx2x-h-file-rewrite.txt

gzipped:
ftp://Net_sys_anon@ftp1.broadcom.com/0001-bnx2x-h-file-rewrite.txt.gz

(will also attache patch inline as reply to this email for review)

Thanks
Eliezer


