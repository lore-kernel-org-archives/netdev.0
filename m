From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Request: Allocate a Netlink Family Number for MPLS
Date: Mon, 1 Dec 2003 15:30:52 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201153052.A3879@infradead.org>
References: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ramon Casellas <casellas@infres.enst.fr>
Content-Disposition: inline
In-Reply-To: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr>; from casellas@infres.enst.fr on Mon, Dec 01, 2003 at 03:36:26PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2003 at 03:36:26PM +0100, Ramon Casellas wrote:
>  #define NETLINK_ARPD           8
> +
> +##if defined(CONFIG_MPLS) || defined(CONFIG_MPLS_MODULE)
> +#define NETLINK_MPLS           9
> +#endif
> +

This is bogus - either it's reserved or not, so the ifdef doesn't
make sense. 

Also given that Dave & co are working on mpls already I wonder
whether it's a good idea to reserve this, but I'll let him speak
for himself :)
