From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 1/5] net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
Date: Tue, 06 Jun 2017 22:15:08 -0400
Message-ID: <87bmq0tufn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37104 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdFGCRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 22:17:24 -0400
In-Reply-To: <20170607000317.14729-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In preparation for supporting multiple CPU ports, remove
> dst->master_netdev and ds->master_netdev and replace them with only one
> instance of the common object we have for a port: struct
> dsa_port::netdev. ds->master_netdev is currently write only and would be
> helpful in the case where we have two switches, both with CPU ports, and
> also connected within each other, which the multi-CPU port patch series
> would address.
>
> While at it, introduce a helper function used in net/dsa/slave.c to
> immediately get a reference on the master network device called
> dsa_master_netdev().
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
