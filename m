From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Fri, 18 Mar 2005 23:33:51 -0600
Message-ID: <200503182333.51470.jdmason@us.ibm.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com> <423133F7.7040400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kosta Todorovic <kostodo@gmail.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <423133F7.7040400@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 11 March 2005 12:00 am, Ben Greear wrote:
> Kosta Todorovic wrote:
> > My company has recently purchased several ZNYX ZX274 network cards.
> > These cards are Four Channel, 10/100 PCI Adapters. They use Intel
> > chipsets.
> >
> > Unfortunately there exists no drivers for linux amd64 architecture.
> > There are 32bit drivers found at:
> > http://www.znyx.com/support/drivers/ZX374_drivers.htm but naturally
> > they wont compile under my amd64 system.
> >
> > The driver itself is called znb.o and can be downloaded from ZNYX's
> > website. I spoke to support staff there but they told me they have
> > discontinued support and development for this series of cards.
> >
> > The system I am running gentoo and have tried both 2.4.x and 2.6.x
> > kernels but no luck.
> >
> > Unfortunately there is NO 64bit drivers available for ANY platform. not
> > even MS.
> >
> > Does anyone know of a customised znb.o driver built for amd64?
> > Is there any chance of anyone modifying the source code of the driver
> > to compile under a amd64 system?
> >
> > I've noticed that "tulip" drivers get loaded as a module at boot time.
> > but they dont function correctly. (lets you start the device and
> > attach ips but cant talk through it)
> >
> > Is there any variants of the tulip driver that will work for this?
> >
> > Help much appreciated.
>
> My personal opinion is that those NICs suck.  I never did get mine
> to work.  I'd suggest getting a DFE-570tx if you can find it, or
> perhaps a p430tx.  You can also get 4-port GigE NICs from Intel for
> around $400 these days...
>
> Ben

Suck or not, it would be good to have these adapters working.  Some people 
might not be willing to spend $400 on a new adapter.  Hopefully some generous 
soul would be willing to spend their valuable time trying to make this work 
(or send me an adapter and I'll give it a go).  

Jon
