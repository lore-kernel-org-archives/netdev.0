From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Sun, 29 Mar 2015 12:42:48 -0700 (PDT)
Message-ID: <20150329.124248.1745435092252856808.davem@davemloft.net>
References: <1427307255.3555533.245187845.14A187CD@webmail.messagingengine.com>
	<1427370594-18807-1-git-send-email-klamm@yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org
To: klamm@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbC2TeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:34:04 -0400
In-Reply-To: <1427370594-18807-1-git-send-email-klamm@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Gushchin <klamm@yandex-team.ru>
Date: Thu, 26 Mar 2015 14:49:54 +0300

> This patch introduces new ipv6 sysctl: ra_default_route_mtu.
> If it's set (> 0), it defines per-route MTU for any new default route
> received by RA.
> 
> This sysctl will help in the following configuration: we want to use
> jumbo-frames for internal networks and default ethernet frames for
> default route. Per-route MTU can only lower per-link MTU, so link MTU
> should be set to ~9000 (statically or via RA).
> 
> Due to dynamic nature of RA, setting MTU for default route will require
> userspace agent, that will monitor changes of default route
> and (re)configure it. Not simple. The suggested sysctl solves this
> problem.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>

This does not apply cleanly to net-next, please respin.
