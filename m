From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPV6: Deprecate All-on-link Assumption
Date: Fri, 10 Sep 2004 15:08:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910150817.1c86df86.davem@davemloft.net>
References: <20040910.104830.121402882.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: pekkas@netcore.fi, netdev@oss.sgi.com, kunitake@linux-ipv6.org,
        yoshfuji@linux-ipv6.org, aesop-core@kame.net
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040910.104830.121402882.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Sep 2004 10:48:30 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> If we don't have IPv6 default routes, we assume all ipv6 destinations 
> are on-link as specified in RFC2461. It, however, is considered harmful now;
> it is problematic with IPv6-capable nodes that do not have off-link
> IPv6 connectivity (eg no default routers) and such nodes will take
> a few seconds until they fall back to use IPv4.
> 
> See <draft-ietf-v6ops-onlinkassumption-02.txt> for details.

Applied, thank you.
