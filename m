From: Cal Peake <cp@absolutedigital.net>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 08:42:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410110835330.8480@linaeum.absolutedigital.net>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
 <416A7484.1030703@portrix.net> <1a50bd3704101105046e66538c@mail.gmail.com>
 <20041011123137.GB28100@zax>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ricky lloyd <ricky.lloyd@gmail.com>, Jan Dittmer <j.dittmer@portrix.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Gibson <hermes@gibson.dropbear.id.au>
In-Reply-To: <20041011123137.GB28100@zax>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 11 Oct 2004, David Gibson wrote:

> On Mon, Oct 11, 2004 at 05:34:20PM +0530, Ricky lloyd wrote:
> > > Isn't the correct fix to declare iobase as (void __iomem *) ?
> > > 
> > 
> > Earlier today i had posted a patch which mainly fixes this same
> > problem with lotsa scsi
> > drivers and tulip drivers. I wondered the same "shouldnt all the addrs
> > be declared as
> > void __iomem* ??". 
> 
> The trouble with that is that for some versions of the orinoco card,
> the iobase refers to a legacy ISA IO address, not a memory-mapped IO
> address (that's the inw()/outw() path in the macro).  That needs an
> integer, rather than a pointer.
> 
> It's not clear to me which way around the cast is less ugly.

I guess the cast is kludgy. I just wanted to shut the warnings up, it 
prints 68 of 'em I believe.

-- Cal
