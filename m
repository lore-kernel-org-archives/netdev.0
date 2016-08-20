From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: ipip6_valid_ip_proto() is static
Date: Fri, 19 Aug 2016 17:08:34 -0700 (PDT)
Message-ID: <20160819.170834.1106689333785836601.davem@davemloft.net>
References: <1471539835.29842.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755741AbcHTAIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:08:35 -0400
In-Reply-To: <1471539835.29842.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Aug 2016 10:03:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes this sparse error :
> net/ipv6/sit.c:1129:6: warning: symbol 'ipip6_valid_ip_proto' was not
> declared. Should it be static?
> 
> 
> Fixes: 49dbe7ae2168b ("sit: support MPLS over IPv4")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This was done in net-next already.
