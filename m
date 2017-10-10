From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v3 net-next] rtnetlink: bridge: use ext_ack instead of
 printk
Date: Tue, 10 Oct 2017 08:47:15 -0600
Message-ID: <7beda9d5-70e4-4aec-4099-e137d925493e@gmail.com>
References: <20171010144427.8341-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:43010 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdJJOrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:47:17 -0400
Received: by mail-pf0-f179.google.com with SMTP id d2so14262413pfh.0
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:47:17 -0700 (PDT)
In-Reply-To: <20171010144427.8341-1-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/17 8:44 AM, Florian Westphal wrote:
> @@ -3666,7 +3666,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>  
>  	dev = __dev_get_by_index(net, ifm->ifi_index);
>  	if (!dev) {
> -		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
> +		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
>  		return -ENODEV;
>  	}
>  
> @@ -3741,7 +3741,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
>  
>  	dev = __dev_get_by_index(net, ifm->ifi_index);
>  	if (!dev) {
> -		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
> +		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
>  		return -ENODEV;
>  	}

missed a couple of 'RTM_* with' strings
