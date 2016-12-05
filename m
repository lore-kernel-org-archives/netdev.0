From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next][PATCH 02/18] RDS: mark few internal functions static
 to make sparse build happy
Date: Mon, 5 Dec 2016 12:45:29 +0300
Message-ID: <604d4954-7302-018e-6f9b-71c0aea6509e@cogentembedded.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
 <1480921073-9140-3-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37265 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751817AbcLEJpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 04:45:32 -0500
Received: by mail-wm0-f51.google.com with SMTP id t79so83426401wmt.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 01:45:31 -0800 (PST)
In-Reply-To: <1480921073-9140-3-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 12/5/2016 9:57 AM, Santosh Shilimkar wrote:

> Fixes below warnings:
> warning: symbol 'rds_send_probe' was not declared. Should it be static?
> warning: symbol 'rds_send_ping' was not declared. Should it be static?
> warning: symbol 'rds_tcp_accept_one_path' was not declared. Should it be static?
> warning: symbol 'rds_walk_conn_path_info' was not declared. Should it be static?
>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
>  net/rds/connection.c | 2 +-
>  net/rds/send.c       | 4 ++--
>  net/rds/tcp_listen.c | 1 +
>  3 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/rds/connection.c b/net/rds/connection.c
> index fe9d31c..26533b2 100644
> --- a/net/rds/connection.c
> +++ b/net/rds/connection.c
> @@ -545,7 +545,7 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
>  }
>  EXPORT_SYMBOL_GPL(rds_for_each_conn_info);
>
> -void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
> +static void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
>  			     struct rds_info_iterator *iter,
>  			     struct rds_info_lengths *lens,
>  			     int (*visitor)(struct rds_conn_path *, void *),

    You now need to realign the continuation lines.

> diff --git a/net/rds/send.c b/net/rds/send.c
> index 77c8c6e..bb13c56 100644
> --- a/net/rds/send.c
> +++ b/net/rds/send.c
[...]

MBR, Sergei
