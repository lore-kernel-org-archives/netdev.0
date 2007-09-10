From: Rick Jones <rick.jones2@hp.com>
Subject: why does tcp_v[46]_conn_request not inc MIB stats
Date: Mon, 10 Sep 2007 11:42:18 -0700
Message-ID: <46E5900A.3010009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:38033 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559AbXIJSmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 14:42:40 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 3801D3572B
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 11:42:19 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id LAA00267
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 11:42:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been digging around to see about inducing /proc/net/tcp to show 
some "interesting" things for listen sockets (eg backlog depth, its max, 
and dropped connection requests).  While there I've noticed that both 
tcp_v[46]_syn_recv_sock and tcp_v[46]conn_request both check that the 
listen queue is full, but only tcp_v[46]_syn_recv_sock increments some 
mib stats for dropped connection requests.

Is that deliberate, or is that a hole in the stats?

rick jones
