From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 03/19] net: bridge: Add support for calling FDB
 external learning under rcu
Date: Mon, 5 Jun 2017 16:36:35 +0300
Message-ID: <7290c1e2-4fb3-8bd6-a8b0-b80799ea95f2@cumulusnetworks.com>
References: <20170605092043.3523-1-jiri@resnulli.us>
 <20170605092043.3523-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38381 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdFENgn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 09:36:43 -0400
Received: by mail-wm0-f45.google.com with SMTP id n195so76063135wmg.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 06:36:38 -0700 (PDT)
In-Reply-To: <20170605092043.3523-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/17 12:20, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> This is done as a preparation to moving the switchdev notifier chain
> to be atomic. The FDB external learning should be called under rtnl
> or rcu.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br.c         | 4 ++--
>  net/bridge/br_fdb.c     | 2 --
>  net/bridge/br_private.h | 6 ++++++
>  3 files changed, 8 insertions(+), 4 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
