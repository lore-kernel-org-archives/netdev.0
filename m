From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 13/13] net: switchdev: Remove bridge bypass
 support from switchdev
Date: Mon, 7 Aug 2017 12:26:12 +0200
Message-ID: <20170807102612.GC2085@nanopsycho.orion>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35367 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752645AbdHGK0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 06:26:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so514150wmd.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 03:26:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Aug 06, 2017 at 03:15:51PM CEST, arkadis@mellanox.com wrote:
>Currently the bridge port flags, vlans, FDBs and MDBs can be offloaded
>through the bridge code, making the switchdev's SELF bridge bypass
>implementation to be redundant. This implies several changes:
>- No need for dump infra in switchdev, DSA's special case is handled
>  privately.
>- Remove obj_dump from switchdev_ops.
>- FDBs are removed from obj_add/del routines, due to the fact that they
>  are offloaded through the bridge notification chain.
>- The switchdev_port_bridge_xx() and switchdev_port_fdb_xx() functions
>  can be removed.
>
>Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
