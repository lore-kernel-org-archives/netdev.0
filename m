From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the tty tree with the net tree
Date: Wed, 28 Apr 2010 23:13:58 -0700
Message-ID: <20100429061358.GA7069@kroah.com>
References: <20100429155655.479e0982.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100429155655.479e0982.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 29, 2010 at 03:56:55PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the tty tree got a conflict in
> include/linux/tty.h between commit
> 9b27105b4a44c54bf91ecd7d0315034ae75684f7 ("net-caif-driver: add CAIF
> serial driver (ldisc)") from the net tree and commit
> 39658c58ebb52fe7a3488fd520aa89c75721fd20 ("tty: n_gsm line discipline")
> from the tty tree.
> 
> I used number 21 for the n_gsm line discipline (see below) and 30 for
> NR_LDISCS and can carry this fix as necessary.

That fix looks fine, thanks,

greg k-h
