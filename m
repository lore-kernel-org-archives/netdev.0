From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] ip6t_LOG and packets with hop-by-hop options
Date: Tue, 6 Jul 2004 13:55:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706135519.028b22b5.davem@redhat.com>
References: <20040706150918.GA5009@penguin.localdomain>
	<20040706160109.GO32707@sunbeam2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040706160109.GO32707@sunbeam2>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 18:01:09 +0200
Harald Welte <laforge@netfilter.org> wrote:

> On Tue, Jul 06, 2004 at 05:09:18PM +0200, Marcel Sebek wrote:
> > Packet with IPPROTO_HOPOPTS extended header isn't logged properly by
> > ip6t_LOG.c. It only prints PROTO=0 and nothing more, because
> > IPPROTO_HOPOPTS=0 and in this file 0 is used to indicate last header.
> > This patch fix it by using IPPROTO_NONE to indicate last header.
> 
> looks fine to me.  Dave, can you please include this to your tree?
> Thanks.

Applied, thanks everyone.
