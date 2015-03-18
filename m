From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next 1/3] tipc: remove redundant call to
 tipc_node_remove_conn
Date: Wed, 18 Mar 2015 15:27:22 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C3B36E0@eusaamb103.ericsson.se>
References: <1426670263-30358-1-git-send-email-erik.hugne@ericsson.com>
 <1426670263-30358-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Erik Hugne <erik.hugne@ericsson.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:45933 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066AbbCRP10 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 11:27:26 -0400
In-Reply-To: <1426670263-30358-2-git-send-email-erik.hugne@ericsson.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Erik Hugne
> Sent: March-18-15 5:18 AM
> To: Richard Alpe; Jon Maloy; ying.xue@windriver.com;
> netdev@vger.kernel.org
> Cc: tipc-discussion@lists.sourceforge.net; Erik Hugne
> Subject: [PATCH net-next 1/3] tipc: remove redundant call to
> tipc_node_remove_conn
> 
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> tipc_node_remove_conn may be called twice if shutdown() is called on a
> socket that have messages in the receive queue.
> Calling this function twice does no harm, but is unnecessary and we remove
> the redundant call.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> ---
>  net/tipc/socket.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c index 813847d..b6295c0
> 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2078,7 +2078,6 @@ restart:
>  					     TIPC_CONN_SHUTDOWN))
>  				tipc_link_xmit_skb(net, skb, dnode,
>  						   tsk->portid);
> -			tipc_node_remove_conn(net, dnode, tsk->portid);
>  		} else {
>  			dnode = tsk_peer_node(tsk);
> 
> --
> 2.1.4
