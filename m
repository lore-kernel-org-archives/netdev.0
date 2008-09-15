From: Greg KH <gregkh@suse.de>
Subject: Re: linux-next: Tree for September 13 (3c509)
Date: Mon, 15 Sep 2008 11:55:55 -0700
Message-ID: <20080915185555.GA31996@suse.de>
References: <20080913162344.ab395285.sfr@canb.auug.org.au> <20080914141757.899f71eb.randy.dunlap@oracle.com> <20080915141149.GA10002@cs181140183.pp.htv.fi> <48CE70CC.7020901@suse.de> <20080915080357.2eaae073.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Reinecke <hare@suse.de>, Adrian Bunk <bunk@kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080915080357.2eaae073.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 15, 2008 at 08:03:57AM -0700, Randy Dunlap wrote:
> On Mon, 15 Sep 2008 16:27:24 +0200 Hannes Reinecke wrote:
> 
> > Hi Adrian,
> > 
> > Adrian Bunk wrote:
> > > On Sun, Sep 14, 2008 at 02:17:57PM -0700, Randy Dunlap wrote:
> > >> drivers/net/3c509.c fails (CONFIG_PM=y) with:
> > >>
> > >> drivers/built-in.o:(.data+0x7dcc): undefined reference to `el3_resume'
> > >> drivers/built-in.o:(.data+0x7e08): undefined reference to `el3_resume'
> > >>
> > >> It seems that this function does not exist in the source file.
> > > 
> > > 
> > > It got removed by:
> > > 
> > > 
> > > commit 107aeb9753159da848f066b26557f0aaab900a90
> > > Author: Hannes Reinecke <hare@suse.de>
> > > Date:   Wed Sep 10 14:16:04 2008 +0200
> > > 
> > >     Driver core: Use dev_get_drvdata() accessors
> > >     
> > >     Deprecated direct access to the ->driver_data field and
> > >     use accessors throughout.
> > >     
> > >     Signed-off-by: Hannes Reinecke <hare@suse.de>
> > >     Cc: Kay Sievers <kay.sievers@vrfy.org>
> > >     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > > 
> > Sorry. Here it is again.
> 
> Ack, that [attached] patch fixes the build.

Now merged in with Hannes's original patch.

thanks,

greg k-h
