From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: add handling for new CAN netlink interface
Date: Mon, 22 May 2017 13:37:05 -0700
Message-ID: <20170522133705.57e13882@xeon-e3>
References: <20170519125449.7214-1-remigiusz.kollataj@mobica.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Remigiusz =?UTF-8?B?S2/FgsWCxIV0YWo=?=
        <remigiusz.kollataj@mobica.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34019 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762391AbdEVUhM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 16:37:12 -0400
Received: by mail-pf0-f182.google.com with SMTP id 9so92701513pfj.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 13:37:12 -0700 (PDT)
In-Reply-To: <20170519125449.7214-1-remigiusz.kollataj@mobica.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 May 2017 14:54:49 +0200
Remigiusz Ko=C5=82=C5=82=C4=85taj         <remigiusz.kollataj@mobica.com> w=
rote:

> This patch adds handling for new CAN netlink interface introduced in
> 4.11 kernel:
> - IFLA_CAN_TERMINATION,
> - IFLA_CAN_TERMINATION_CONST,
> - IFLA_CAN_BITRATE_CONST,
> - IFLA_CAN_DATA_BITRATE_CONST
>=20
> Output example:
> $ip -d link show can0
> 6: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group def=
ault qlen 10
>     link/can  promiscuity 0
>     can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
>           bitrate 80000
>              [   20000,    33333,    50000,    80000,    83333,   100000,
>                 125000,   150000,   175000,   200000,   225000,   250000,
>                 275000,   300000,   500000,   625000,   800000,  1000000 ]
>           termination 0 [ 0, 120 ]
>           clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_s=
egs 65535
>=20
> Signed-off-by: Remigiusz Ko=C5=82=C5=82=C4=85taj <remigiusz.kollataj@mobi=
ca.com>

What is output without the -d flag?
In general iproute2 show commands are designed to be invertable.
I.e the show command looks like the same command to set.

Printing the bitrates and the format of the state output looks quite differ=
ent
than the set command. Is it limited to detail (-d)?
