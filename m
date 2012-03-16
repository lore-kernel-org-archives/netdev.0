From: "Roberto De Ioris" <roberto@unbit.it>
Subject: [RFC] add SIOBKLGQ command to unix socket ioctl
Date: Fri, 16 Mar 2012 07:49:18 +0100
Message-ID: <2f0e25f9694e236485bd5c6736ba314e.squirrel@manage.unbit.it>
Reply-To: roberto@unbit.it
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabretooth.unbit.it ([81.174.68.19]:20860 "EHLO
	sabretooth.unbit.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab2CPGyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 02:54:54 -0400
Received: from magneto.unbit.it (unknown [192.168.0.61])
	by sabretooth.unbit.it (Postfix) with ESMTP id AC556200D17D
	for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 07:49:18 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone, in the uWSGI project we use TCP_INFO
datas to know the status of the socket backlog queue (this helps
the master process identifying overloads)

http://projects.unbit.it/uwsgi/browser/master.c#L202

We would like to have a similar feature in unix sockets.
After a bit of investigation we decided to add an ioctl to get the backlog
size. This has been applied only to unix socket but i suppose it could be
used for other network families.

Patch follow

-- 
Roberto De Ioris
http://unbit.it
