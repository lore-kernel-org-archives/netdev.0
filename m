From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] ipmr: fix mfc notification flags
Date: Thu, 20 Mar 2014 16:25:09 -0400 (EDT)
Message-ID: <20140320.162509.1575646696193274136.davem@davemloft.net>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
	<1395247671-9356-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759591AbaCTUZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:25:12 -0400
In-Reply-To: <1395247671-9356-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 19 Mar 2014 17:47:50 +0100

> Commit 8cd3ac9f9b7b ("ipmr: advertise new mfc entries via rtnl") reuses the
> function ipmr_fill_mroute() to notify mfc events.
> But this function was used only for dump and thus was always setting the
> flag NLM_F_MULTI, which is wrong in case of a single notification.
> 
> Libraries like libnl will wait forever for NLMSG_DONE.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
