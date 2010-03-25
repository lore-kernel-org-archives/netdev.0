From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_hashlimit: IPV6 bugfix
Date: Thu, 25 Mar 2010 17:26:06 +0100
Message-ID: <4BAB8E9E.3080509@trash.net>
References: <1269533869.3626.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269533869.3626.41.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> A missing break statement in hashlimit_ipv6_mask(), and masks
> between /64 and /95 are not working at all...

Applied, thanks Eric.
