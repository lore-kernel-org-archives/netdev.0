From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [2.6 patch] net/sunrpc/rpcb_clnt.c: make struct rpcb_program
 static
Date: Tue, 12 Jun 2007 19:14:48 -0400
Message-ID: <466F28E8.3010101@oracle.com>
References: <20070612230313.GZ3588@stusta.de>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020700040903050002030800"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56505 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbXFLXTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 19:19:45 -0400
In-Reply-To: <20070612230313.GZ3588@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020700040903050002030800
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Adrian Bunk wrote:
> This patch makes the needlessly global struct rpcb_program static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

> ---
> 
>  net/sunrpc/rpcb_clnt.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-2.6.22-rc4-mm2/net/sunrpc/rpcb_clnt.c.old	2007-06-12 23:25:01.000000000 +0200
> +++ linux-2.6.22-rc4-mm2/net/sunrpc/rpcb_clnt.c	2007-06-12 23:25:19.000000000 +0200
> @@ -118,7 +118,7 @@
>  #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
>  
>  static void			rpcb_getport_done(struct rpc_task *, void *);
> -extern struct rpc_program	rpcb_program;
> +static struct rpc_program	rpcb_program;
>  
>  struct rpcbind_args {
>  	struct rpc_xprt *	r_xprt;
> @@ -616,7 +616,7 @@
>  
>  static struct rpc_stat rpcb_stats;
>  
> -struct rpc_program rpcb_program = {
> +static struct rpc_program rpcb_program = {
>  	.name		= "rpcbind",
>  	.number		= RPCBIND_PROGRAM,
>  	.nrvers		= ARRAY_SIZE(rpcb_version),
> 


--------------020700040903050002030800
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnVybDpodHRwOi8vb3NzLm9yYWNsZS5jb20v
fmNlbC8NCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQNCg0K
--------------020700040903050002030800--
