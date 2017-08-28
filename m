From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [ethtool] ethtool: Remove UDP Fragmentation Offload use from
 ethtool
Date: Mon, 28 Aug 2017 08:00:11 -0700
Message-ID: <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
        netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34342 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdH1PAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:00:13 -0400
Received: by mail-pf0-f194.google.com with SMTP id p69so477997pfk.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 08:00:13 -0700 (PDT)
In-Reply-To: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-28 at 15:38 +0300, Tariq Toukan wrote:
> From: Shaker Daibes <shakerd@mellanox.com>
> 
> UFO was removed in kernel, here we remove it in ethtool app.
> 
> Fixes the following issue:
> Features for ens8:
> Cannot get device udp-fragmentation-offload settings: Operation not supported
> 
> Tested with "make check"
> 
> Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---


Hi guys

I would rather remove the warning, but leave the ability to switch UFO
on machines running old kernel but a recent ethtool.

ethtool does not need to be downgraded every time we boot an old
kernel ;)

Thanks !
