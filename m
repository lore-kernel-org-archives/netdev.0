From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] nfp: move BPF offload code into app
Date: Wed, 31 May 2017 17:58:47 -0400 (EDT)
Message-ID: <20170531.175847.540441798107923887.davem@davemloft.net>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdEaV6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 17:58:49 -0400
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 31 May 2017 08:06:42 -0700

> This series moves the eBPF offload code out of netdev/vNIC handling and
> starts building the nfp_app.  Port init is moved into the apps as well
> because various apps associate vNICs, representors with ports differently.
> 
> First patch adds a helper for updating tc stats which has been waiting 
> in my tree to be included in any moderately related series.
> 
> Next series will bring communicating with FW using control messages,
> then representors, BPF maps, tc flower... :)

Looks good, series applied.
