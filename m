From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip6tables: use skb->len for accounting
Date: Fri, 23 Jul 2010 16:24:58 +0200
Message-ID: <4C49A63A.9060809@trash.net>
References: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 05:31, Changli Gao wrote:
> ip6tables: use skb->len for accounting
> 
> ipv6_hdr(skb)->payload_len is ZERO and can't be used for accounting, if the
> payload is a Jumbo Payload specified in RFC2675.

Applied, thanks.
