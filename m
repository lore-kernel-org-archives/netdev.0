From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [2.6 patch] make sunrpc/xprtsock.c:xs_setup_{udp,tcp}() static
Date: Wed, 24 Oct 2007 14:41:15 -0400
Message-ID: <471F91CB.1020607@oracle.com>
References: <20071024162402.GB30533@stusta.de>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060300020602040407090407"
Cc: Tom Talpey <tmt@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36232 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200AbXJXSlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 14:41:35 -0400
In-Reply-To: <20071024162402.GB30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060300020602040407090407
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Adrian Bunk wrote:
> xs_setup_{udp,tcp}() can now become static.

ACK.  Sorry this was overlooked.

> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  include/linux/sunrpc/xprtsock.h |    6 ------
>  net/sunrpc/xprtsock.c           |    4 ++--
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> 833a31c8caef70589f33be8e3a1fc9d8e01ce3c2 
> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
> index 2c6c2c2..c2a46c4 100644
> --- a/include/linux/sunrpc/xprtsock.h
> +++ b/include/linux/sunrpc/xprtsock.h
> @@ -9,12 +9,6 @@
>  
>  #ifdef __KERNEL__
>  
> -/*
> - * Socket transport setup operations
> - */
> -struct rpc_xprt *xs_setup_udp(struct xprt_create *args);
> -struct rpc_xprt *xs_setup_tcp(struct xprt_create *args);
> -
>  int		init_socket_xprt(void);
>  void		cleanup_socket_xprt(void);
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 02298f5..2f630a5 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1828,7 +1828,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
>   * @args: rpc transport creation arguments
>   *
>   */
> -struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
> +static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>  {
>  	struct sockaddr *addr = args->dstaddr;
>  	struct rpc_xprt *xprt;
> @@ -1894,7 +1894,7 @@ struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>   * @args: rpc transport creation arguments
>   *
>   */
> -struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
> +static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  {
>  	struct sockaddr *addr = args->dstaddr;
>  	struct rpc_xprt *xprt;
> 


--------------060300020602040407090407
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRvdCBj
b20NCnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2
MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQN
Cg0K
--------------060300020602040407090407--
