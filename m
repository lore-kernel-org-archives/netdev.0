From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 13/13] net: switchdev: Remove bridge bypass
 support from switchdev
Date: Mon, 7 Aug 2017 11:13:01 -0700
Message-ID: <ded711bb-ed92-ecce-8c5c-613a240dd205@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36827 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdHGSNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:13:06 -0400
Received: by mail-wm0-f68.google.com with SMTP id d40so1887081wma.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:13:06 -0700 (PDT)
In-Reply-To: <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> Currently the bridge port flags, vlans, FDBs and MDBs can be offloaded
> through the bridge code, making the switchdev's SELF bridge bypass
> implementation to be redundant. This implies several changes:
> - No need for dump infra in switchdev, DSA's special case is handled
>   privately.
> - Remove obj_dump from switchdev_ops.
> - FDBs are removed from obj_add/del routines, due to the fact that they
>   are offloaded through the bridge notification chain.
> - The switchdev_port_bridge_xx() and switchdev_port_fdb_xx() functions
>   can be removed.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
