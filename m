From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix error creating L2TP tunnels
Date: Wed, 17 Feb 2016 15:36:35 -0500 (EST)
Message-ID: <20160217.153635.188688180228329961.davem@davemloft.net>
References: <1455506684-27033-1-git-send-email-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhong@brocade.com
To: mark.tomlinson@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbcBQUgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 15:36:37 -0500
In-Reply-To: <1455506684-27033-1-git-send-email-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Date: Mon, 15 Feb 2016 16:24:44 +1300

> A previous commit (33f72e6) added notification via netlink for tunnels
> when created/modified/deleted. If the notification returned an error,
> this error was returned from the tunnel function. If there were no
> listeners, the error code ESRCH was returned, even though having no
> listeners is not an error. Other calls to this and other similar
> notification functions either ignore the error code, or filter ESRCH.
> This patch checks for ESRCH and does not flag this as an error.
> 
> Reviewed-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
> Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.

But it seems like we might want to filter out that error in a common
location instead of in all of these various spots.
