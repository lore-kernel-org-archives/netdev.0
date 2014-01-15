From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: TI CPSW Ethernet Tx performance regression
Date: Wed, 15 Jan 2014 18:18:49 +0530
Message-ID: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:44503 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbaAOMs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 07:48:57 -0500
Received: from dflxv15.itg.ti.com ([128.247.5.124])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id s0FCmuWL016975
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 06:48:56 -0600
Received: from DFLE72.ent.ti.com (dfle72.ent.ti.com [128.247.5.109])
	by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id s0FCmue8028923
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 06:48:56 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am seeing a performance regression with CPSW driver on AM335x EVM. AM335x EVM
CPSW has 3.2 kernel support [1] and Mainline support from 3.7. When I am
comparing the performance between 3.2 and 3.13-rc4. TCP receive performance of
CPSW between 3.2 and 3.13-rc4 is same (~180Mbps) but TCP Transmit performance
is poor comparing to 3.2 kernel. In 3.2 kernel is it *256Mbps* and in 3.13-rc4
it is *70Mbps*

Iperf version is *iperf version 2.0.5 (08 Jul 2010) pthreads* on both PC and EVM

On UDP transmit also performance is down comparing to 3.2 kernel. In 3.2 it is
196Mbps for 200Mbps band width and in 3.13-rc4 it is 92Mbps

Can someone point me out where can I look for improving Tx performance. I also
checked whether there is Tx descriptor over flow and there is none. I have
tries 3.11 and some older kernel, all are giving ~75Mbps Transmit performance
only.

[1] - http://arago-project.org/git/projects/?p=linux-am33x.git;a=summary

Regards
Mugunthan V N
