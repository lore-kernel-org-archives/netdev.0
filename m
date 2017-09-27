From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v3 06/12] net: mroute: Check if rule is a default
 rule
Date: Wed, 27 Sep 2017 17:38:28 +0300
Message-ID: <2cb46b48-6736-e514-11ca-4119d9d768c3@cumulusnetworks.com>
References: <20170927062322.5476-1-jiri@resnulli.us>
 <20170927062322.5476-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch, linyunsheng@huawei.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:55504 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751664AbdI0Oib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 10:38:31 -0400
Received: by mail-wr0-f175.google.com with SMTP id l39so16882718wrl.12
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 07:38:30 -0700 (PDT)
In-Reply-To: <20170927062322.5476-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/09/17 09:23, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> When the ipmr starts, it adds one default FIB rule that matches all packets
> and sends them to the DEFAULT (multicast) FIB table. A more complex rule
> can be added by user to specify that for a specific interface, a packet
> should be look up at either an arbitrary table or according to the l3mdev
> of the interface.
> 
> For drivers willing to offload the ipmr logic into a hardware but don't
> want to offload all the FIB rules functionality, provide a function that
> can indicate whether the FIB rule is the default multicast rule, thus only
> one routing table is needed.
> 
> This way, a driver can register to the FIB notification chain, get
> notifications about FIB rules added and trigger some kind of an internal
> abort mechanism when a non default rule is added by the user.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v2->v3:
>  - Use the already existing ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
> v1->v2:
>  - Update the lastuse MFC entry field too, in addition to packets an bytes.
> ---
>  include/linux/mroute.h |  7 +++++++
>  net/ipv4/ipmr.c        | 12 ++++++++++++
>  2 files changed, 19 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
