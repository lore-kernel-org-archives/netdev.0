From: Yinghai Lu <yinghai@kernel.org>
Subject: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 02:17:09 -0700
Message-ID: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:51149 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab0DKJRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 05:17:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

caused by:

commit 2626419ad5be1a054d350786b684b41d23de1538
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Apr 8 11:32:30 2010 -0700

    tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb

it will make sshd server, telnet server and vnc server doesn't respond
connecting request anymore.

YH
