From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH resend] netfilter: change IPS_*_BIT to IPS_*
Date: Tue, 18 Jan 2011 15:05:51 +0100
Message-ID: <4D359E3F.4040804@trash.net>
References: <1295090445-14431-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Tim Gardner <tim.gardner@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295090445-14431-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.01.2011 12:20, Changli Gao wrote:
> My previous patch made a mistake when converting atomic_set to a normal
> bit 'or'. IPS_*_BIT should be replaced with IPS_*.

Then please state this clearly in the subject instead of calling it
a resend. Also we use "netfilter: <subsystem>: <change description>",
as I've told you multiple times already.

> 
>   commit 76a2d3bcfcc86e2a8044258515b86492a37631a3
>   Author: Changli Gao <xiaosuo@gmail.com>
>   Date:   Mon Nov 15 11:59:03 2010 +0100
> 
>   netfilter: nf_nat: don't use atomic bit operation
> 
>   As we own the conntrack and the others can't see it until we confirm it,
>   we don't need to use atomic bit operation on ct->status.

Applied, thanks.
