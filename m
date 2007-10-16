From: Max Asbock <masbock@us.ibm.com>
Subject: BNX2X driver: kernel panic when running netperf
Date: Tue, 16 Oct 2007 16:34:40 -0700
Message-ID: <1192577680.5730.12.camel@w-amax.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:56694 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbXJPXfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 19:35:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9GNacqq021882
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 19:36:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9GNZ7u4555386
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 19:35:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9GNYugK024639
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 19:34:56 -0400
Received: from [9.47.17.144] (w-amax.beaverton.ibm.com [9.47.17.144])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l9GNYtbW024434
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 19:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tested the bnx2x driver (0001-BNX2X-0.40.10a-net-2.6.24.patch) with
netdev-2.6.24 git tree and found that I can reproducibly panic the
system when running netperf with the TCP_STREAM test.
I copied the following information from the panic message:
RIP: 0xc02fff32
net_rx_action +0x142/0x190
...
do_softirq
...
Kernel panic - not syncing
Fatal exception in interrupt.

Please let me what additional information is useful. 

Max


  


