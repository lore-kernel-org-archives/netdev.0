From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net-next
 tree
Date: Wed, 7 Dec 2016 08:02:55 +0100
Message-ID: <20161207070255.GB9824@kroah.com>
References: <20161207150447.160b7735@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jarod Wilson <jarod@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161207150447.160b7735@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 03:04:47PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflict in:
> 
>   drivers/staging/slicoss/slicoss.c
> 
> between commit:
> 
>   a52ad514fdf3 ("net: deprecate eth_change_mtu, remove usage")
> 
> from the net-next tree and commit:
> 
>   0af72df267f2 ("staging: slicoss: remove the staging driver")
> 
> from the staging tree.
> 
> I fixed it up (I just removed the file) and can carry the fix as
> necessary. This is now fixed as far as linux-next is concerned, but any
> non trivial conflicts should be mentioned to your upstream maintainer
> when your tree is submitted for merging.  You may also want to consider
> cooperating with the maintainer of the conflicting tree to minimise any
> particularly complex conflicts.

Thanks, we did coordinate this :)

greg k-h
