From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: fix sysctl memory leak
Date: Mon, 14 Mar 2011 19:21:09 +0100
Message-ID: <4D7E5C95.4090002@trash.net>
References: <20110310101422.62006620@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110310101422.62006620@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.03.2011 19:14, Stephen Hemminger wrote:
> Message in log because sysctl table was not empty at netns exit
>  WARNING: at net/sysctl_net.c:84 sysctl_net_exit+0x2a/0x2c()
> 
> Instrumenting showed that the nf_conntrack_timestamp was the entry
> that was being created but not cleared.

Applied, thanks Stephen.
