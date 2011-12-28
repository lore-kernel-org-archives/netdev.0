From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tcp_diag: Report max ack backlog as separate nla
Date: Wed, 28 Dec 2011 13:44:00 -0500 (EST)
Message-ID: <20111228.134400.1090343588247448850.davem@davemloft.net>
References: <4EFB1B86.7090905@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab1L1SoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:44:03 -0500
In-Reply-To: <4EFB1B86.7090905@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 28 Dec 2011 17:37:10 +0400

> Since it's thrown away from the core message let's nonetheless report it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Nope, we're not doing this.  We must keep reporting it in the core
message.
