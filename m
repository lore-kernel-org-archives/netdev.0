From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/packet: remove unused PGV_FROM_VMALLOC
 definition.
Date: Wed, 19 Jul 2017 16:28:31 -0700 (PDT)
Message-ID: <20170719.162831.1865265583339620884.davem@davemloft.net>
References: <1500405810-20611-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com, xiaosuo@gmail.com,
        shanwei@cn.fujitsu.com
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932529AbdGSX2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 19:28:32 -0400
In-Reply-To: <1500405810-20611-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Tue, 18 Jul 2017 22:23:30 +0300

> This patch removes the definition of PGV_FROM_VMALLOC from af_packet.c.
> The PGV_FROM_VMALLOC definition was already removed by 
> commit 441c793a5650 ("net: cleanup unused macros in net directory"),
> and its usage was removed even before by commit c56b4d90123b 
> ("af_packet: remove pgv.flags"); but it was added back by mistake later on,
> in commit f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation").
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thanks Rami.
