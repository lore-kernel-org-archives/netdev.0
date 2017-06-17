From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: Fix legacy probing
Date: Sat, 17 Jun 2017 13:52:04 -0400
Message-ID: <87d1a2pkmz.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170616234211.20341-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, jcobham@questertangent.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46306 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752125AbdFQRyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:54:20 -0400
In-Reply-To: <20170616234211.20341-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> After commit 6d3c8c0dd88a ("net: dsa: Remove master_netdev and
> use dst->cpu_dp->netdev") and a29342e73911 ("net: dsa: Associate
> slave network device with CPU port") we would be seeing NULL pointer
> dereferences when accessing dst->cpu_dp->netdev too early. In the legacy
> code, we actually know early in advance the master network device, so
> pass it down to the relevant functions.
>
> Fixes: 6d3c8c0dd88a ("net: dsa: Remove master_netdev and use dst->cpu_dp->netdev")
> Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
> Reported-by: Jason Cobham <jcobham@questertangent.com>
> Tested-by: Jason Cobham <jcobham@questertangent.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
