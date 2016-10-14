From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: fix ip6_tnl_lookup
Date: Fri, 14 Oct 2016 10:02:03 -0400 (EDT)
Message-ID: <20161014.100203.681553712270913922.davem@davemloft.net>
References: <20161011203454.F2B87341C3E@junk-ub14>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: junk@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47288 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753009AbcJNOCH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:02:07 -0400
In-Reply-To: <20161011203454.F2B87341C3E@junk-ub14>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Fedorenko <junk@yandex-team.ru>
Date: Tue, 11 Oct 2016 22:47:20 +0300

> The commit ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel
> endpoints.") introduces support for wildcards in tunnels endpoints,
> but in some rare circumstances ip6_tnl_lookup selects wrong tunnel
> interface relying only on source or destination address of the packet
> and not checking presence of wildcard in tunnels endpoints. Later in
> ip6_tnl_rcv this packets can be dicarded because of difference in
> ipproto even if fallback device have proper ipproto configuration.
> 
> This patch adds checks of wildcard endpoint in tunnel avoiding such
> behavior
> 
> Fixes: ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel
> endpoints.")
> 
> Signed-off-by: Vadim Fedorenko <junk@yandex-team.ru>

Applied and queued up for -stable.
