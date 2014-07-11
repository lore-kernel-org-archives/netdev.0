From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 4/4] net: rtnetlink - make create_link take
 name_assign_type
Date: Fri, 11 Jul 2014 12:23:35 -0700 (PDT)
Message-ID: <20140711.122335.833933211386013460.davem@davemloft.net>
References: <1405026066-2547-1-git-send-email-teg@jklm.no>
	<1405026066-2547-5-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dh.herrmann@gmail.com, kay@vrfy.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405026066-2547-5-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Thu, 10 Jul 2014 23:01:06 +0200

> This passes down NET_NAME_USER (or NET_NAME_ENUM) to alloc_netdev(),
> for any device created over rtnetlink.
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> ---
>  drivers/net/veth.c      | 11 ++++++++---
>  include/net/rtnetlink.h |  1 +
>  net/core/rtnetlink.c    | 12 ++++++++----
>  3 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index b4a10bc..5058700 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -319,6 +319,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
>  	struct nlattr *peer_tb[IFLA_MAX + 1], **tbp;
>  	struct ifinfomsg *ifmp;
>  	struct net *net;
> +	unsigned char name_assign_type;
>  
>  	/*
>  	 * create and register peer first

Please order local variables in reverse-christmas-tree order, in this case
name_assign_type should be placed on the line before the declaration for
"ifmp".
