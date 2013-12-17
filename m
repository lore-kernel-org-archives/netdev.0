From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: show protocol type in sockprotoname of fdinfo
Date: Tue, 17 Dec 2013 16:38:59 -0500 (EST)
Message-ID: <20131217.163859.881643028001329684.davem@davemloft.net>
References: <1387178381-30289-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab3LQVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:39:00 -0500
In-Reply-To: <1387178381-30289-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Mon, 16 Dec 2013 16:19:41 +0900

> In 600e177920df936d03b807780ca92c662af98990 "system.sockprotoname"
> xattrs is added to sockets enumerated under /proc/$PID/fd.
> It is intended mainly to be used from lsof.
> 
> The patch was accepted. However, I think using xattrs under procfs is
> special hack for lsof. Normally the user of procfs may want to use cat
> command(or write syscall) to retrieve informations from the fs.
> 
> This patch introduces "sockprotoname" field to /proc/PID/fdinfo of socket.
> So the user can use cat command to retrieve the protocol information.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

We're not providing multiple ways of doing the same thing, people
should have considered things more completely when the original
patch was proposed.

Sorry.
