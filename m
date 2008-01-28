From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: appearing again: kernel: eth0: too many iterations (6) in nv_nic_irq
Date: Mon, 28 Jan 2008 11:32:55 -0200
Message-ID: <18333.55687.621653.838538@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:60823 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbYA1Nc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 08:32:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that this problem with NVidia's nic comes up more and more...
>From time to time we get this in the log:

Jan 27 14:43:12 duvel kernel: eth0: too many iterations (6) in nv_nic_irq.

We algo get

Jan 27 11:32:43 duvel kernel: KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)

But at different moments, as shown above. Are they related? What's the
meaning of the "assertion failed" one?

The messages are more likely to appear when traffic is high
(>500Mb/s). This is with 2.6.22.16.

Any suggestions?
