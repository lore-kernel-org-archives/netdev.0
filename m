From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 11:01:22 -0400
Message-ID: <87shhc6471.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no> <20170731113355.4284-3-privat@egil-hjelmeland.no> <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <3207fcff-8318-9b17-c546-026ab1a1511b@egil-hjelmeland.no> <87o9s01xb3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <3eafb133-2b39-a1c5-6c01-917799fb6320@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33634 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752438AbdGaPER (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 11:04:17 -0400
In-Reply-To: <3eafb133-2b39-a1c5-6c01-917799fb6320@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Would doing
>
> -	chip->ds = dsa_switch_alloc(chip->dev, DSA_MAX_PORTS);
> +	chip->ds = dsa_switch_alloc(chip->dev, LAN9303_NUM_PORTS);
>
> at the same time be good, or breaking the scope of the patch?

It is indeed out of scope. You may want to add a first commit "net: dsa:
lan9303: introduce LAN9303_NUM_PORTS" for instance.


Thanks,

        Vivien
