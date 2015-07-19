From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: #ifdefify sk_classid member of struct
 sock
Date: Sun, 19 Jul 2015 11:42:28 -0700 (PDT)
Message-ID: <20150719.114228.179586744105997642.davem@davemloft.net>
References: <1437329861-11758-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1437329861-11758-1-git-send-email-minipli@googlemail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 20:17:41 +0200

> The sk_classid member is only required when CONFIG_CGROUP_NET_CLASSID is
> enabled. #ifdefify it to reduce the size of struct sock on 32 bit
> systems, at least.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Are you sure NFT_META_CGROUP cannot enter nft_meta_get_eval()?  If so it'll
WARN_ON().

I really don't like changes like this.
