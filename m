From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: will 2 cpu simultaneously  process packets which have same hash
 value on multiqueue nic?
Date: Wed, 19 May 2010 22:37:25 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497F5B7D6@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:40891 "HELO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752425Ab0ETFhi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:37:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

will 2 cpu simultaneously  process packets which have same hash value on multiqueue nic?

let 's take broadcom 57711 bnx2x_main.c as an example:

#1 packet1->queue=1
#2 packet2->queue=1

will cpu1 and cpu2 execute the function " bnx2x_rx_int" in parallel, to receive packet1 & packet2

or it just depend on smp_affinity setting?

thanks
jon
