From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove dead skb_iter code
Date: Wed, 2 Mar 2005 14:25:42 -0800
Message-ID: <20050302142542.2ae86040.davem@davemloft.net>
References: <20050302101035.61786113@dxpl.pdx.osdl.net>
	<20050302102025.23f479f9.davem@davemloft.net>
	<20050302220735.GB25847@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050302220735.GB25847@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 22:07:35 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> Maybe because the removal is right.  This code is not dependent on
> any networking internals so it can easily live in a netfilter support
> module instead of bloating everyones kernels.

Fine, I'll kill it for now.  (I also happen to know that it might
be used for ipv4 fragmentation tricks too, but that's also in the
future).
