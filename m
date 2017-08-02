From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 4/6] mlxsw: spectrum_router: Don't check state
 when refreshing offload indication
Date: Wed, 2 Aug 2017 17:21:25 -0600
Message-ID: <d0866a4f-079a-04b5-b268-d9d1a2546470@gmail.com>
References: <20170802075606.1090-1-jiri@resnulli.us>
 <20170802075606.1090-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35743 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbdHBXV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:21:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id j68so6491181pfc.2
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 16:21:27 -0700 (PDT)
In-Reply-To: <20170802075606.1090-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 1:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Previous patch removed the reliance on the counter in the FIB info to
> set the offload indication, so we no longer need to keep an offload
> state on each FIB entry and can just set or unset the RTNH_F_OFFLOAD
> flag in each nexthop.
> 
> This is also necessary because we're going to need to refresh the
> offload indication whenever the nexthop group associated with the FIB
> entry is refreshed. Current check would prevent us from marking a newly
> resolved nexthop as offloaded if the FIB entry is already marked as
> offloaded.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 ++-----------
>  1 file changed, 2 insertions(+), 11 deletions(-)

Tested-by: David Ahern <dsahern@gmail.com>
