From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging-next tree with the net
	tree
Date: Wed, 5 May 2010 21:20:48 -0700
Message-ID: <20100506042048.GA25425@kroah.com>
References: <20100506140543.d6f3841f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Prashant P. Shah" <pshah.mumbai@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100506140543.d6f3841f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 06, 2010 at 02:05:43PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging-next tree got a conflict in
> drivers/staging/arlan/arlan-main.c between commit
> 22bedad3ce112d5ca1eaf043d4990fa2ed698c87 ("net: convert multicast list to
> list_head") from the net tree and commit
> dd730b627cf8ff0b9d20df94fd31b6192b188710 ("Staging: arlan: fixed
> unnecessary whitespace style issue in arlan-main.c") from the
> staging-next tree.
> 
> I fixed it up (see below - this is bigger than is would otherwise be
> because there is a conflict with another patch that was previously
> reported) and can carry the fix as necessary.

Thanks for doing this.  Hm, the arlan driver is scheduled to be deleted
in .35, so it would make things easier if I just do it now to keep these
kinds of merge issues from happening.  I'll queue that up tomorrow.

thanks,

greg k-h
