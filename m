From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] rtnetlink: fix fdb notification flags
Date: Thu, 20 Mar 2014 16:25:03 -0400 (EDT)
Message-ID: <20140320.162503.536482270990113339.davem@davemloft.net>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759591AbaCTUZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:25:06 -0400
In-Reply-To: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 19 Mar 2014 17:47:49 +0100

> Commit 3ff661c38c84 ("net: rtnetlink notify events for FDB NTF_SELF adds and
> deletes") reuses the function nlmsg_populate_fdb_fill() to notify fdb events.
> But this function was used only for dump and thus was always setting the
> flag NLM_F_MULTI, which is wrong in case of a single notification.
> 
> Libraries like libnl will wait forever for NLMSG_DONE.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
