From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] remove dead skb_iter code
Date: Wed, 2 Mar 2005 22:07:35 +0000
Message-ID: <20050302220735.GB25847@infradead.org>
References: <20050302101035.61786113@dxpl.pdx.osdl.net> <20050302102025.23f479f9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050302102025.23f479f9.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2005 at 10:20:25AM -0800, David S. Miller wrote:
> On Wed, 2 Mar 2005 10:10:35 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > The code iterate over skb_frags is defined but not used by any
> > existing kernel code.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> Rusty and co.'s planned netfilter packet parsing code will use
> the iterators.  Send a patch to add a comment to this effect
> or something as I'm tired of folks trying to remove this code.
> :-)

Maybe because the removal is right.  This code is not dependent on
any networking internals so it can easily live in a netfilter support
module instead of bloating everyones kernels.
