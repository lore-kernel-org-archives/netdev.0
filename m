From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 2/2] mlxsw: spectrum: Propagate extack further
 for bridge enslavements
Date: Fri, 6 Oct 2017 12:24:43 -0600
Message-ID: <c678acc9-940a-b0e0-ba27-a34b19fcf13e@gmail.com>
References: <20171005214000.14022-1-jiri@resnulli.us>
 <20171005214000.14022-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38739 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdJFSYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 14:24:44 -0400
Received: by mail-pg0-f66.google.com with SMTP id j3so3395354pga.5
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 11:24:44 -0700 (PDT)
In-Reply-To: <20171005214000.14022-3-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/17 3:40 PM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> The code that actually takes care of bridge offload introduces a few
> more non-trivial constraints with regards to bridge enslavements.
> Propagate extack there to indicate the reason.
> 
> $ ip link add link enp1s0np1 name enp1s0np1.10 type vlan id 10
> $ ip link add link enp1s0np1 name enp1s0np1.20 type vlan id 20
> $ ip link add name br0 type bridge
> $ ip link set dev enp1s0np1.10 master br0
> $ ip link set dev enp1s0np1.20 master br0
> Error: spectrum: Can not bridge VLAN uppers of the same port.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 ++++--
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 ++-
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 25 +++++++++++++++-------
>  3 files changed, 23 insertions(+), 11 deletions(-)

Acked-by: David Ahern <dsahern@gmail.com>
