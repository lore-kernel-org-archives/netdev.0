From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/1] driver: tun: Forbid to set IFF_TUN and
 IFF_TAP at the same time
Date: Sun, 23 Oct 2016 17:40:43 -0400 (EDT)
Message-ID: <20161023.174043.122548847583183053.davem@davemloft.net>
References: <1477047735-26003-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, edumazet@google.com, pabeni@redhat.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756745AbcJWVkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 17:40:45 -0400
In-Reply-To: <1477047735-26003-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri, 21 Oct 2016 19:02:15 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Current tun driver permits the ifr_flags is set with IFF_TUN and
> IFF_TAP at the same time. But actually there is only IFF_TUN flag
> works. And it does not make sense these two flags are set, so add
> this check.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

We've allowed this for too long to start failing on it now, sorry.
