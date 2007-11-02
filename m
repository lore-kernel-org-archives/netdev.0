From: Max Asbock <masbock@us.ibm.com>
Subject: Re: [RFC][BNX2X] .h files rewrite
Date: Fri, 02 Nov 2007 16:35:54 -0700
Message-ID: <1194046554.6369.20.camel@w-amax.beaverton.ibm.com>
References: <1193602670.4836.25.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33578 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbXKBXgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 19:36:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA2NZwZE007646
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 19:35:58 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA2NZw5h466356
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 19:35:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA2NZvBu026991
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 19:35:58 -0400
In-Reply-To: <1193602670.4836.25.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-10-28 at 22:17 +0200, Eliezer Tamir wrote:
> Dave,
> 
> Please take a look and tell me if this is better than the last attempt.
> 
> Main changes:
> 
> * Rewrite of the init code: 
> 	1. Full rewrite of the generated code into something easier to read.
> 	2. Removed zeroes by adding a zero command.
> 	3. Big chucks of data are read by the chip using the DMA engine (instead of being written by the driver).
> 	4. Gzipped more of the data.
> 
> * Removed BE microcode, the swapping is done in the driver instead.
> 
> * Rewrite of the HSI - broke it into three files bnx2x_hsi.h bnx2x_reg.h and bnx2x_fw_defs.h
> 
> * Fixed SPARSE warnings.
> 
> * Fixed all but three checkpatch.pl warnings. (IMHO they are false positives)
> 
> The diff is against latest net-2.6.
> 
> ftp link:
> ftp://Net_sys_anon@ftp1.broadcom.com/0001-bnx2x-h-file-rewrite.txt
> 
> gzipped:
> ftp://Net_sys_anon@ftp1.broadcom.com/0001-bnx2x-h-file-rewrite.txt.gz
> 
> (will also attache patch inline as reply to this email for review)
> 

I built the newest bnx2x code against the net-2.6 kernel and ran a
number of stress tests with netperf and pktgen. I did not encounter any
errors.

Max


