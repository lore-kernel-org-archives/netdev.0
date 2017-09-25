From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 02/12] ipmr: Add reference count to MFC
 entries
Date: Mon, 25 Sep 2017 12:27:27 +0300
Message-ID: <32395cd4-f6f4-47ea-8337-0f642f2b9355@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:51010 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932404AbdIYJ1a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:27:30 -0400
Received: by mail-wm0-f47.google.com with SMTP id b195so17469321wmb.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:27:30 -0700 (PDT)
In-Reply-To: <20170924172212.10096-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Next commits will introduce MFC notifications through the atomic
> fib_notification chain, thus allowing modules to be aware of MFC entries.
> 
> Due to the fact that modules may need to hold a reference to an MFC entry,
> add reference count to MFC entries to prevent them from being freed while
> these modules use them.
> 
> The reference counting is done only on resolved MFC entries currently.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - Add comment for the mfc_cache.mfc_un.res.refcount field, similarly to
>    all other fields in the struct
> ---
>  include/linux/mroute.h | 21 +++++++++++++++++++++
>  net/ipv4/ipmr.c        |  8 +++++---
>  2 files changed, 26 insertions(+), 3 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
