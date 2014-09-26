From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ipv6: Return an error when adding an already
 existing tunnel
Date: Fri, 26 Sep 2014 00:44:36 -0400 (EDT)
Message-ID: <20140926.004436.1456898816192905571.davem@davemloft.net>
References: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbaIZEoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 00:44:38 -0400
In-Reply-To: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 22 Sep 2014 10:07:23 +0200

> The ipv6 tunnel locate functions should not return an existing
> tunnel if create is true. Otherwise it is possible to add the
> same tunnel multiple times without getting an error.
> 
> All our ipv6 tunnels have this bug from the very beginning.
> Only the sit tunnel was fixed some years ago with:
> 
> commit 8db99e57175 ("sit: Fail to create tunnel, if it already exists").
> 
> This patchset fixes the remaining ipv6 tunnels.

Series applied and queued up for -stable, thanks.
