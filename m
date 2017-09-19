From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 8139too: revisit napi_complete_done() usage
Date: Mon, 18 Sep 2017 20:57:29 -0700 (PDT)
Message-ID: <20170918.205729.1447641244948185208.davem@davemloft.net>
References: <20170410121102.GM30290@intel.com>
        <20170918194630.GH4914@intel.com>
        <1505765023.29839.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: ville.syrjala@linux.intel.com, edumazet@google.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbdISD5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 23:57:36 -0400
In-Reply-To: <1505765023.29839.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Sep 2017 13:03:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems we have to be more careful in napi_complete_done()
> use. This patch is not a revert, as it seems we can
> avoid bug that Ville reported by moving the napi_complete_done()
> test in the spinlock section.
> 
> Many thanks to Ville for detective work and all tests.
> 
> Fixes: 617f01211baf ("8139too: use napi_complete_done()")
> Reported-by: Ville Syrjälä <ville.syrjala@linux.intel.com>
> Tested-by: Ville Syrjälä <ville.syrjala@linux.intel.com>

Applied and queued up for -stable.
