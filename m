From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netlink: allow to pass data pointer to
 netlink_dump_start() callback
Date: Sun, 26 Feb 2012 14:27:07 -0500 (EST)
Message-ID: <20120226.142707.1012222011717616484.davem@davemloft.net>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
	<1330129817-28199-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab2BZT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 14:28:11 -0500
In-Reply-To: <1330129817-28199-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Sat, 25 Feb 2012 01:30:16 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This patch allows you to pass a data pointer that can be
> accessed from the dump callback.
> 
> Netfilter is going to use this patch to provide filtered dumps
> to user-space. This is specifically interesting in ctnetlink that
> may handle lots of conntrack entries. We can save precious
> cycles by skipping the conversion to TLV format of conntrack
> entries that are not interesting for user-space.
> 
> More specifically, ctnetlink will include one operation to allow
> to filter the dumping of conntrack entries by ctmark values.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
