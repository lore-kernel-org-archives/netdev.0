From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 06/12] net: mroute: Check if rule is a default
 rule
Date: Mon, 25 Sep 2017 12:38:15 +0300
Message-ID: <d72ca561-4657-0223-d61c-0b0267318a5a@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:49724 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933992AbdIYJiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:38:18 -0400
Received: by mail-wm0-f47.google.com with SMTP id r74so17588040wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:38:18 -0700 (PDT)
In-Reply-To: <20170924172212.10096-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
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
>  include/linux/mroute.h |  7 +++++++
>  net/ipv4/ipmr.c        | 10 ++++++++++
>  2 files changed, 17 insertions(+)
> 

I saw the comment and am fine with the patch either way, so you can
add my:

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks
