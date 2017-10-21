From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Sat, 21 Oct 2017 03:04:46 +0100 (WEST)
Message-ID: <20171021.030446.967534081159629805.davem@davemloft.net>
References: <20171019135048.4306-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753222AbdJUCEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 22:04:55 -0400
In-Reply-To: <20171019135048.4306-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 19 Oct 2017 15:50:28 +0200

> This patchset is a bit bigger, but most of the patches are doing the
> same changes in multiple classifiers and drivers. I could do some
> squashes, but I think it is better split.
> 
> This is another dependency on the way to shared block implementation.
> The goal is to remove use of tp->q in classifiers code.
> 
> Also, this provides drivers possibility to track binding of blocks to
> qdiscs. Legacy drivers which do not support shared block offloading.
> register one callback per binding. That maintains the current
> functionality we have with ndo_setup_tc. Drivers which support block
> sharing offload register one callback per block which safes overhead.
> 
> Patches 1-4 introduce the binding notifications and per-block callbacks
> Patches 5-8 add block callbacks calls to classifiers
> Patches 9-17 do convert from ndo_setup_tc calls to block callbacks for
>              classifier offloads in drivers
> Patches 18-20 do cleanup

Series applied.
