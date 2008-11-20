From: dann frazier <dannf@hp.com>
Subject: soft lockups/OOM after unix socket fixes
Date: Thu, 20 Nov 2008 15:03:27 -0700
Message-ID: <20081120220326.GE24416@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:24117 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbYKTWDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 17:03:31 -0500
Received: from g1t0039.austin.hp.com (g1t0039.austin.hp.com [16.236.32.45])
	by g1t0029.austin.hp.com (Postfix) with ESMTP id D11DE381BD
	for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 22:03:30 +0000 (UTC)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by g1t0039.austin.hp.com (Postfix) with ESMTP id B9B91340F6
	for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 22:03:30 +0000 (UTC)
Received: from localhost (ldl.fc.hp.com [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 5F83A39C07C
	for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 15:03:30 -0700 (MST)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl.fc.hp.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rIrre5XxHA-P for <netdev@vger.kernel.org>;
	Thu, 20 Nov 2008 15:03:29 -0700 (MST)
Received: from krebs (krebs.dannf [10.8.0.7])
	by ldl.fc.hp.com (Postfix) with ESMTP id 6A09C39C009
	for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 15:03:27 -0700 (MST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hey,
 I'm noticing that if I run the unix.c program from [1] in a tight
loop on 2.6.28-rc5, I get frequent soft lockups. Eventually, the OOM
killer kicks in and starts taking out other processes.

 I've posted a console log here:
   http://free.linux.hp.com/~dannf/unix-soft-lockups.log

[1] http://marc.info/?l=linux-netdev&m=122593044330973&w=2


--
dann frazier
