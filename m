From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 02/12] net: dsa: Remove prepare phase for FDB
Date: Thu, 06 Jul 2017 14:20:49 -0400
Message-ID: <87r2xtctq6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com> <1499268990-19251-3-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51636 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751846AbdGFSXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 14:23:21 -0400
In-Reply-To: <1499268990-19251-3-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> The prepare phase for FDB add is unneeded because most of DSA devices
> can have failures during bus transactions (SPI, I2C, etc.), thus, the
> prepare phase cannot guarantee success of the commit stage.
>
> The support for learning FDB through notification chain, which will be
> introduced in the following patches, will provide the ability to notify
> back the bridge about successful offload.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
