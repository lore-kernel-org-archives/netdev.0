From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ppp: implement x-netns support
Date: Tue, 25 Aug 2015 14:11:51 -0700 (PDT)
Message-ID: <20150825.141151.1600040073857838816.davem@davemloft.net>
References: <7bed7d73ab7508dd1898bcb83d9523772a89bcf9.1440408699.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755847AbbHYVLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:11:52 -0400
In-Reply-To: <7bed7d73ab7508dd1898bcb83d9523772a89bcf9.1440408699.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 24 Aug 2015 11:35:30 +0200

> Let packets move from one netns to the other at PPP encapsulation and
> decapsulation time.
> 
> PPP units and channels remain in the netns in which they were
> originally created. Only the net_device may move to a different
> namespace. Cross netns handling is thus transparent to lower PPP
> layers (PPPoE, L2TP, etc.).
> 
> PPP devices are automatically unregistered when their netns gets
> removed. So read() and poll() on the unit file descriptor will
> respectively receive EOF and POLLHUP. Channels aren't affected.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
> v2: rebase on top of net-next

Applied, thank you.
