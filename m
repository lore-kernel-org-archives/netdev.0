From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf: make skb_make_writable() return bool
Date: Mon, 02 Aug 2010 17:45:44 +0200
Message-ID: <4C56E828.9040404@trash.net>
References: <1280559384-25197-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280559384-25197-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.07.2010 08:56, Changli Gao wrote:
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

> -int skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
> +bool skb_make_writable(struct sk_buff *skb, unsigned int writable_len)

You can change things like this when making actual changes to the code,
but this is just useless noise in the changelogs and makes it harder
to locate real changes in the history.
