From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 3/6] mlxsw: spectrum_router: Provide offload
 indication using nexthop flags
Date: Wed, 2 Aug 2017 17:20:23 -0600
Message-ID: <92521fd0-c504-7d74-6f30-02870876e344@gmail.com>
References: <20170802075606.1090-1-jiri@resnulli.us>
 <20170802075606.1090-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36457 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdHBXUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:20:25 -0400
Received: by mail-pg0-f68.google.com with SMTP id y129so7812369pgy.3
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 16:20:25 -0700 (PDT)
In-Reply-To: <20170802075606.1090-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 1:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> In a similar fashion to previous patch, use the nexthop flags to provide
> offload indication instead of the FIB info's flags.
> 
> In case a nexthop in a multipath route can't be offloaded (gateway's MAC
> can't be resolved, for example), then its offload flag isn't set.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 38 ++++++++++++++++++++--
>  1 file changed, 36 insertions(+), 2 deletions(-)
> 
>

Tested-by: David Ahern <dsahern@gmail.com>
