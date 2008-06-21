From: Andi Kleen <andi@firstfloor.org>
Subject: (!sk->sk_forward_alloc) assertation failure in 2.6.26-rc5
Date: Sat, 21 Jun 2008 20:23:00 +0200
Message-ID: <485D4704.9010805@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38478 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbYFUSXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 14:23:20 -0400
Received: from [78.53.156.19] (f053156019.adsl.alicedsl.de [78.53.156.19])
	by one.firstfloor.org (Postfix) with ESMTP id 907BC1AD0020
	for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 20:34:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FYI saw this on a system which was running 2.6.25rc5 for quite some time.

It might have been related to me restarting the NFS server (not 100% sure)

KERNEL: assertion (!sk->sk_forward_alloc) failed at /home/lsrc/misc/linux/net/ipv4/af_inet.c (157)	

Happened only once so far.

-Andi
