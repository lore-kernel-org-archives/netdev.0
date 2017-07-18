From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 11/11] net: switchdev: Remove bridge bypass support from switchdev
Date: Tue, 18 Jul 2017 14:11:12 -0400
Message-ID: <871spdboov.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-12-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53920 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdGRSOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:14:15 -0400
In-Reply-To: <1500387624-4361-12-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> Currently the bridge port flags, vlans, FDBs and MDBs can be offloaded
> through the bridge code, making the switchdev's SELF bridge bypass
> implementation to be redundant. This implies several changes:
> - No need for dump infra in switchdev, DSA's special case is handled
>   privately.
> - Remove obj_dump from switchdev_ops.
> - FDBs are removed from obj_add/del routines, due to the fact that they
>   are offloaded through the bridge notifcation chain.

                                     notification*
                                     
> - The switchdev_port_bridge_xx() and switchdev_port_fdb_xx() functions
>   can be removed.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
