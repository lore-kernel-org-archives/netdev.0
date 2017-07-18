From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/11] net: dsa: Remove redundant MDB dump support
Date: Tue, 18 Jul 2017 13:42:19 -0400
Message-ID: <87a841bq10.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-9-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51380 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdGRRpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 13:45:01 -0400
In-Reply-To: <1500387624-4361-9-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> Currently the MDB HW database is synced with the bridge's one, thus,
> There is no need to support special dump functionality.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> ---
>  drivers/net/dsa/microchip/ksz_common.c |  9 ---------
>  drivers/net/dsa/mv88e6xxx/chip.c       | 24 ------------------------
>  include/net/dsa.h                      |  4 ----
>  net/dsa/dsa_priv.h                     |  2 --
>  net/dsa/port.c                         | 11 -----------
>  net/dsa/slave.c                        |  3 ---

Same request as in the VLAN dump deletion patch, please.


Thank you,

        Vivien
