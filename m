From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 3/3] ip6mr: fix mfc notification flags
Date: Thu, 20 Mar 2014 07:39:50 +0000
Message-ID: <20140320073950.GE16640@casper.infradead.org>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
 <1395247671-9356-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57012 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaCTHju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 03:39:50 -0400
Content-Disposition: inline
In-Reply-To: <1395247671-9356-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/14 at 05:47pm, Nicolas Dichtel wrote:
> Commit 812e44dd1829 ("ip6mr: advertise new mfc entries via rtnl") reuses the
> function ip6mr_fill_mroute() to notify mfc events.
> But this function was used only for dump and thus was always setting the
> flag NLM_F_MULTI, which is wrong in case of a single notification.
> 
> Libraries like libnl will wait forever for NLMSG_DONE.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
