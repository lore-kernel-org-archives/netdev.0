From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/3] rtnetlink: fix fdb notification flags
Date: Thu, 20 Mar 2014 07:38:31 +0000
Message-ID: <20140320073831.GC16640@casper.infradead.org>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56475 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaCTHid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 03:38:33 -0400
Content-Disposition: inline
In-Reply-To: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/14 at 05:47pm, Nicolas Dichtel wrote:
> Commit 3ff661c38c84 ("net: rtnetlink notify events for FDB NTF_SELF adds and
> deletes") reuses the function nlmsg_populate_fdb_fill() to notify fdb events.
> But this function was used only for dump and thus was always setting the
> flag NLM_F_MULTI, which is wrong in case of a single notification.
> 
> Libraries like libnl will wait forever for NLMSG_DONE.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
