From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 5/6] mlxsw: spectrum_router: Refresh offload
 indication upon group refresh
Date: Wed, 2 Aug 2017 17:20:36 -0600
Message-ID: <ef81d692-1607-1869-aedf-79e42fcdc12c@gmail.com>
References: <20170802075606.1090-1-jiri@resnulli.us>
 <20170802075606.1090-6-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35822 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdHBXUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:20:38 -0400
Received: by mail-pf0-f174.google.com with SMTP id t86so26659428pfe.2
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 16:20:38 -0700 (PDT)
In-Reply-To: <20170802075606.1090-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 1:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Now that we provide offload indication using the nexthop's flags we must
> refresh the offload indication whenever the offload state within the
> group changes.
> 
> This didn't matter until now, as offload indication was provided using
> the FIB info flags and multipath routes were marked as offloaded as long
> as one of the nexthops was offloaded.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 

Tested-by: David Ahern <dsahern@gmail.com>
