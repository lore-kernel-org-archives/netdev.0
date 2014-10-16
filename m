From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix description of portid
Date: Thu, 16 Oct 2014 14:53:06 -0400 (EDT)
Message-ID: <20141016.145306.1638536656633583664.davem@davemloft.net>
References: <1413467271-6385-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaJPSxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 14:53:08 -0400
In-Reply-To: <1413467271-6385-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 16 Oct 2014 15:47:51 +0200

> Avoid confusion between pid and portid.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.

We've been plagued by this confusion forever, because the value used to
even be stored in struct members and variables named 'pid'.
