From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: unify logic evaluating inet6_dev's accept_ra
 property
Date: Sat, 01 Dec 2012 11:37:06 -0500 (EST)
Message-ID: <20121201.113706.939862337727720397.davem@davemloft.net>
References: <1354307159-24193-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	tore@fud.no
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab2LAQhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:37:08 -0500
In-Reply-To: <1354307159-24193-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Fri, 30 Nov 2012 22:25:59 +0200

> As of 026359b [ipv6: Send ICMPv6 RSes only when RAs are accepted], the
> logic determining whether to send Router Solicitations is identical
> to the logic determining whether kernel accepts Router Advertisements.
> 
> However the condition itself is repeated in several code locations.
> 
> Unify it by introducing 'ipv6_accept_ra()' accessor.
> 
> Also, simplify the condition expression, making it more readable.
> No semantic change.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied.
