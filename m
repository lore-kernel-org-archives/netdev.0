From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] CAIF: fix indentation for function arguments
Date: Wed, 06 Mar 2013 16:07:17 -0800
Message-ID: <1362614837.2093.30.camel@joe-AO722>
References: <1362606521-16848-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362606521-16848-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-03-06 at 23:48 +0200, Silviu-Mihai Popescu wrote:
> This lines up function arguments on second and subsequent lines at the
> first column after the openning parenthesis of the first line.
[]
> diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
[]
> @@ -301,10 +301,10 @@ static void dev_flowctrl(struct net_device *dev, int on)
>  }
>  
>  void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *caifdev,
> -			struct cflayer *link_support, int head_room,
> -			struct cflayer **layer, int (**rcv_func)(
> -				struct sk_buff *, struct net_device *,
> -				struct packet_type *, struct net_device *))
> +		     struct cflayer *link_support, int head_room,
> +		     struct cflayer **layer, int (**rcv_func)(
> +		     struct sk_buff *, struct net_device *,
> +		     struct packet_type *, struct net_device *))

This makes it seem that caif_enroll_dev takes more args.

I think this style is better (aligned to appropriate open paren)

void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *caifdev,
		     struct cflayer *link_support, int head_room,
		     struct cflayer **layer,
		     int (**rcv_func)(struct sk_buff *, struct net_device *,
				      struct packet_type *, struct net_device *))

[]

> @@ -301,8 +301,8 @@ static int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
>  
>  int caif_connect_client(struct net *net, struct caif_connect_request *conn_req,
>  			struct cflayer *adap_layer, int *ifindex,
> -				int *proto_head,
> -				int *proto_tail)
> +			int *proto_head,
> +			int *proto_tail)

You could fill to 80 here.
