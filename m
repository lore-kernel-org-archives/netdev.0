From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/18] tipc: add ability to order and receive
 topology events in driver
Date: Thu, 12 Oct 2017 11:54:39 -0700 (PDT)
Message-ID: <20171012.115439.600933914570246341.davem@davemloft.net>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
        <1507816959-31787-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdJLSym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:54:42 -0400
In-Reply-To: <1507816959-31787-2-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 12 Oct 2017 16:02:22 +0200

> @@ -288,6 +289,7 @@ static int tipc_receive_from_sock(struct tipc_conn *con)
>  }
>  
>  static int tipc_accept_from_sock(struct tipc_conn *con)
> +
>  {

This whitespace change seems unintentional.

> +bool tipc_topsrv_kern_subscr(struct net *net, u32 port, u32 type,
> +			     u32 lower, u32 upper, int *conid)
> +{
> +	struct tipc_server *s;
> +	struct tipc_conn *con;
> +	struct tipc_subscriber *scbr;
> +	struct tipc_subscr sub;

Please order local variables from longest to shortest line.

>  static void tipc_send_to_sock(struct tipc_conn *con)
>  {
>  	int count = 0;
>  	struct tipc_server *s = con->server;
> +	struct tipc_event *evt;
>  	struct outqueue_entry *e;
>  	struct msghdr msg;
>  	int ret;

Likewise.
