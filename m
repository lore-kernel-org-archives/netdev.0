From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Thu, 18 Mar 2004 22:16:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318221645.2b67e433.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
	<20040308115858.75cdddca.davem@redhat.com>
	<4059CF17.8090907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059CF17.8090907@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 17:32:23 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch adds policy lookups to ip_route_me_harder and makes NAT
> reroute for any change that affects route/policy lookups.

Why are you deleting that "fl.proto = iph->protocol;" line in
net/core/netfilter.c?  Is something else going to set it properly?
