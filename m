From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Multicast problem
Date: Tue, 16 Oct 2007 18:49:47 +0200
Message-ID: <1192553387.30006.29.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:40672 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752337AbXJPQt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 12:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I can't get my PowerPC 83xx(eth driver ucc_qeth) board to reply on a
multcast ping:
  ping -t 1 -c 2 224.0.0.1
unless I do ifconfig eth1 promisc and
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

I guess I am missing something, but what?

Kernel: 2.6.23

 Jocke

