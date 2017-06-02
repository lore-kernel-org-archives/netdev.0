From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()
Date: Fri, 02 Jun 2017 15:33:47 -0400
Message-ID: <87d1amyyjo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170602193123.23930-1-f.fainelli@gmail.com> <20170602193123.23930-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41238 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdFBTfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:35:52 -0400
In-Reply-To: <20170602193123.23930-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> There was no reason for duplicating the code that initializes
> ds->enabled_port_mask in both dsa_parse_ports_dn() and
> dsa_parse_ports(), instead move this to dsa_ds_parse() which is early
> enough before ops->setup() has run.
>
> While at it, we can now make dsa_is_cpu_port() check ds->cpu_port_mask
> which is a step towards being multi-CPU port capable.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
