From: wc8348@cs.utexas.edu
Subject: Problem about Setting TCP Congestion Window to a Small Constant
Date: Sat, 22 Nov 2014 10:29:40 -0600
Message-ID: <a7b958c622a1f1ebed77d4ce44109ceb.squirrel@webmail.cs.utexas.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poliwhirl.cs.utexas.edu ([128.83.120.135]:41197 "EHLO
	poliwhirl.cs.utexas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbaKVQiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 11:38:00 -0500
Received: from webmail.cs.utexas.edu (www-data@localhost [127.0.0.1])
	by poliwhirl.cs.utexas.edu (8.14.4/8.14.4/Debian-2ubuntu2.1) with ESMTP id sAMGTdbt009770
	for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 10:29:40 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
     My name is Wenzhi Cui, a graduate student working on TCP congestion
control in Linux Kernel. I have a problem about congestion control in
linux kernel.

     Recently I am playing with TCP Congestion Control Protocol by setting
the congestion window size to a constant, say 1, and measure the TCP
flow throughput to see the relationship between cwnd size and
transmission rate (on a stable environment).

     The problem is, when I am setting the snd_cwnd to 1, the real
transmission rate is around 25MBps. However, since I am testing TCP
on our department network with 1Gbps (which is 125MBps) bandwidth and
300 micro seconds Round trip time (measured by analyzing tcpdump
trace). So the theoretical sending rate should be
CWND * MSS / RTT = 1 * 1460 Byte / 300 us = around 5 MBps
which is far less than the observed 25 MBps bandwidth. I have taken a look
at tcp_cong.c, tcp_input output.c, etc. but I still cannot find the
problem.

     Can somebody help me figure out what is missing, maybe what may
affect the real TCP transmission other than CWND or what will happen
when CWND is set to a very small constant?

Thanks,
Wenzhi Cui
