From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v9 4/9] net: set name_assign_type when setting
 names via ioctls
Date: Thu, 17 Jul 2014 16:20:40 -0700 (PDT)
Message-ID: <20140717.162040.171795478640839195.davem@davemloft.net>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
	<1405584370-30054-5-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-5-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Thu, 17 Jul 2014 10:06:05 +0200

> @@ -2787,10 +2788,13 @@ static int gsm_create_network(struct gsm_dlci *dlci, struct gsm_netconfig *nc)
>  	pr_debug("create network interface");
>  
>  	netname = "gsm%d";
> -	if (nc->if_name[0] != '\0')
> +	if (nc->if_name[0] != '\0') {
>  		netname = nc->if_name;
> -	net = alloc_netdev(sizeof(struct gsm_mux_net), netname,
> -			   NET_NAME_UNKNOWN, gsm_mux_net_init);
> +		name_assign_type = NET_NAME_USER;
> +	}
> +	net = alloc_netdev(sizeof(struct gsm_mux_net),
> +			netname, name_assign_type,
> +			gsm_mux_net_init);

The indentation is now not correct.  For a function call, all arguments on the
second and subsequent line, must start exactly at the first column after the
openning parenthesis of the function call.
