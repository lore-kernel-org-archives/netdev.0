From: Andi Kleen <ak@suse.de>
Subject: Dead loop on netdevice eth0, fix it urgently! in -git2
Date: Sun, 29 Apr 2007 15:51:55 +0200
Message-ID: <200704291551.55730.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35686 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756477AbXD2NwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Apr 2007 09:52:00 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id C4DAD1223E
	for <netdev@vger.kernel.org>; Sun, 29 Apr 2007 15:51:59 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



FYI,

While testing 2.6.21-git2 on a NFS root box and pulling the ethernet cable of the NFS 
server for a few seconds I got this

nfs: server 10.23.204.1 not responding, still trying
nfs: server 10.23.204.1 not responding, still trying
Dead loop on netdevice eth0, fix it urgently!
nfs: server 10.23.204.1 OK
nfs: server 10.23.204.1 OK

I haven't investigated closely.

-Andi


