From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] NDISC: ensure responding to NS without
 link-layer information.
Date: Thu, 16 Sep 2004 13:14:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916131428.39736d91.davem@davemloft.net>
References: <20040916.125921.56481183.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040916.125921.56481183.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 12:59:21 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> When sending NA in response to NS, we may not know the 
> link-layer address for the destination of the NA 
> since unicast NS is not required to include its link-layer information.
> In this case, we first need to resolve the link-layer address.
> (RFC 2461 7.2.4)
> 
> We now create neighbour entry for the destination 
> and link-layer information will be automatically solved 
> in the output path.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Patch applied, thank you.
