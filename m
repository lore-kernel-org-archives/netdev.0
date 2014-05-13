From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] Make mark-based routing work better with
 multiple separate networks.
Date: Tue, 13 May 2014 18:35:51 -0400 (EDT)
Message-ID: <20140513.183551.1997490064935443892.davem@davemloft.net>
References: <1400001455-30267-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpa@google.com, ja@ssi.bg,
	hannes@stressinduktion.org, eric.dumazet@gmail.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaEMWfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:35:53 -0400
In-Reply-To: <1400001455-30267-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 13 May 2014 10:17:32 -0700

> Mark-based routing (ip rule fwmark 17 lookup 100) combined with
> either iptables marking (iptables -j MARK --set-mark 17) or
> application-based marking (the SO_MARK setsockopt) are a good
> way to deal with connecting simultaneously to multiple networks.
> 
> Each network can be given a routing table, and ip rules can
> be configured to make different fwmarks select different
> networks. Applications can select networks them by setting
> appropriate socket marks, and iptables rules can be used to
> handle non-aware applications, enforce policy, etc.
> 
> This patch series improves functionality when mark-based routing
> is used in this way. Current behaviour has the following
> limitations:

Series applied, thanks.
