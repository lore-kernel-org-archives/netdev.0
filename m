From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] extend taskstats API to support networking accounts
Date: Thu, 23 Feb 2012 03:34:34 -0500 (EST)
Message-ID: <20120223.033434.1801978370536071654.davem@davemloft.net>
References: <4F45F73F.3000708@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raise.sail@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486Ab2BWIej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 03:34:39 -0500
In-Reply-To: <4F45F73F.3000708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <raise.sail@gmail.com>
Date: Thu, 23 Feb 2012 16:22:23 +0800

> This patch only records TCP/UDP/Raw-IP traffic so far, and adding
> other protocol support is easy.

It shouldn't even be necessary to put any code into specific
protocols, it should instead be done at some generic location
so that all protocols are supported transparently.
