From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Latency difference between fifo and pfifo_fast
Date: Mon, 05 Dec 2011 23:10:13 -0500 (EST)
Message-ID: <30c2e9e0-4208-4c19-9e43-31f95e13575d@jasiiieee>
References: <8f05fdb0-6e4c-4adf-b8d1-bd67a0dc114f@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:52030 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756398Ab1LFDJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 22:09:50 -0500
In-Reply-To: <8f05fdb0-6e4c-4adf-b8d1-bd67a0dc114f@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  We are trying to minimize latency on our iSCSI SAN.  The network is entirely dedicated to the iSCSI traffic.  Since all the traffic is the same, would it make sense to change the qdisc for that interface to fifo from the default pfifo_fast or is the latency difference between the two completely negligible? Thanks - John
