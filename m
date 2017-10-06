From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 1/2] mlxsw: spectrum: Add extack for VLAN
 enslavements
Date: Fri, 6 Oct 2017 12:24:33 -0600
Message-ID: <1d2e6cb3-6936-2f1d-5d06-22e8d1a00cd2@gmail.com>
References: <20171005214000.14022-1-jiri@resnulli.us>
 <20171005214000.14022-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34623 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdJFSYf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 14:24:35 -0400
Received: by mail-pf0-f193.google.com with SMTP id g65so17379415pfe.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 11:24:34 -0700 (PDT)
In-Reply-To: <20171005214000.14022-2-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/17 3:39 PM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Similar to physical ports, enslavement of VLAN devices can also fail.
> Use extack to indicate why the enslavement failed.
> 
> $ ip link add link enp1s0np1 name enp1s0np1.10 type vlan id 10
> $ ip link add name bond0 type bond mode 802.3ad
> $ ip link set dev enp1s0np1.10 master bond0
> Error: spectrum: VLAN devices only support bridge and VRF uppers.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

Acked-by: David Ahern <dsahern@gmail.com>
