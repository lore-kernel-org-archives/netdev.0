From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: take reference on channels netns
Date: Wed, 23 Mar 2016 14:37:35 -0400 (EDT)
Message-ID: <20160323.143735.2175353198407088561.davem@davemloft.net>
References: <4dbdfa8e264d5a635865c6e843c122daf9be4f8d.1458747209.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gorcunov@gmail.com, sploving1@gmail.com,
	paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbcCWShi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 14:37:38 -0400
In-Reply-To: <4dbdfa8e264d5a635865c6e843c122daf9be4f8d.1458747209.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 23 Mar 2016 16:38:55 +0100

> Let channels hold a reference on their network namespace.
> Some channel types, like ppp_async and ppp_synctty, can have their
> userspace controller running in a different namespace. Therefore they
> can't rely on them to preclude their netns from being removed from
> under them.
 ...
> Fixes: 273ec51dd7ce ("net: ppp_generic - introduce net-namespace functionality v2")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks!
