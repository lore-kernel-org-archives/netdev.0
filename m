From: Greg KH <greg@kroah.com>
Subject: Re: [BK PATCHES] 2.6.x net driver oops fixes
Date: Thu, 10 Mar 2005 12:31:12 -0800
Message-ID: <20050310203112.GA20337@kroah.com>
References: <422F59E8.2090707@pobox.com> <20050310202548.GV5389@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>, Linus Torvalds <torvalds@osdl.org>,
        stable@kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Chris Wright <chrisw@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050310202548.GV5389@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2005 at 12:25:48PM -0800, Chris Wright wrote:
> * Jeff Garzik (jgarzik@pobox.com) wrote:
> 
> > This will update the following files:
> > 
> >  drivers/net/sis900.c    |   41 +++++++++++++++++++++--------------------
> >  drivers/net/via-rhine.c |    3 +++
> 
> The via-rhine fix is already in the stable queue.  But the sis900 oops
> fix does not apply to the stable tree.  It relies on a few intermediate
> patches.  Appears to still be an issue for the older version which is in
> 2.6.11.  Here's a stab at a backport.  Would you like to review/validate
> or drop this one?

The pci_name() portion of this patch is not necessary for the -stable
tree.  Care to remove it?

thanks,

greg k-h
