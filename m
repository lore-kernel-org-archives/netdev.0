From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: remove useless device duplication test
 in l2tp_eth_create()
Date: Thu, 27 Apr 2017 16:32:32 -0400 (EDT)
Message-ID: <20170427.163232.820514637547781457.davem@davemloft.net>
References: <95d793ebf07f9ec7aefa496ed2b1432aa9dc8aa8.1493199657.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033845AbdD0Uce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:32:34 -0400
In-Reply-To: <95d793ebf07f9ec7aefa496ed2b1432aa9dc8aa8.1493199657.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 26 Apr 2017 11:54:47 +0200

> There's no need to verify that cfg->ifname is unique at this point.
> register_netdev() will return -EEXIST if asked to create a device with
> a name that's alrealy in use.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Yep that's right, applied, thanks!
