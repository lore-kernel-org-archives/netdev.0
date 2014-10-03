From: Tomas Mozes <tomas.mozes@shmu.sk>
Subject: xen netback
Date: Fri, 03 Oct 2014 10:00:27 +0200
Message-ID: <2a859434a5de41a8f19ced4c228200cf@shmu.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.shmu.sk ([91.199.31.35]:46088 "EHLO mailgw.shmu.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbaJCIKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 04:10:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by mailgw.shmu.sk (Postfix) with ESMTP id 1AAC88100A
	for <netdev@vger.kernel.org>; Fri,  3 Oct 2014 08:00:29 +0000 (UTC)
Received: from mailgw.shmu.sk ([127.0.0.1])
	by localhost (mailgw.shmu.sk [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MCp5Lisb5XlY for <netdev@vger.kernel.org>;
	Fri,  3 Oct 2014 08:00:27 +0000 (UTC)
Received: from srv-mail-relay.kol.shmu.sk (srv-mail-ng.kol.shmu.sk [10.20.8.23])
	by mailgw.shmu.sk (Postfix) with ESMTP id F1F467D004
	for <netdev@vger.kernel.org>; Fri,  3 Oct 2014 08:00:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by srv-mail-relay.kol.shmu.sk (Postfix) with ESMTP id EE5C63702F
	for <netdev@vger.kernel.org>; Fri,  3 Oct 2014 10:00:27 +0200 (CEST)
Received: from srv-mail.kol.shmu.sk ([127.0.0.1])
	by localhost (srv-mail.shmu.sk [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zUYjPqWH55F3 for <netdev@vger.kernel.org>;
	Fri,  3 Oct 2014 10:00:27 +0200 (CEST)
Received: from mail.shmu.sk (localhost [127.0.0.1])
	by srv-mail.kol.shmu.sk (Postfix) with ESMTP id BEDFD220FA
	for <netdev@vger.kernel.org>; Fri,  3 Oct 2014 10:00:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some of our xen-dom0 machines running 3.14.x we have a problem of 
domU's freezing. This has been fixed in:
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/drivers/net/xen-netback/netback.c?id=59ae9fc67007da8b5aea7b0a31c3607745cfbfee

and the patch has been included in 3.16.x, but I cannot find it in the 
current longterm releases. We have an open gentoo bug report about it:
https://bugs.gentoo.org/show_bug.cgi?id=517852

This bug doesn't happen on all xen-dom0 machines, but I can confirm that 
on the problematic machine after applying the aforemention patch, the 
problem gone away and the system has been running for 60 days without 
problems.

Please consider applying the patch to the longterm kernels.

Thank you
