From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: ipv6: fix overlap check for fragments
Date: Fri, 12 Nov 2010 08:52:57 +0100
Message-ID: <4CDCF259.5070601@trash.net>
References: <4CD3F0F8.5030205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CD3F0F8.5030205@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.11.2010 12:56, Shan Wei wrote:
> The type of FRAG6_CB(prev)->offset is int, skb->len is *unsigned* int,
> and offset is int.
> 
> Without this patch, type conversion occurred to this expression, when
> (FRAG6_CB(prev)->offset + prev->len) is less than offset.

Applied, thanks Shan.
