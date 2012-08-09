From: Arun MURTHY <arun.murthy@stericsson.com>
Subject: RE: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Thu, 9 Aug 2012 11:53:12 +0200
Message-ID: <F45880696056844FA6A73F415B568C695B0E797048@EXDCVYMBSTM006.EQ1STM.local>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
 <1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
 <20120807183809.GC26990@kroah.com>
 <F45880696056844FA6A73F415B568C695B0E796A03@EXDCVYMBSTM006.EQ1STM.local>
 <20120808133748.GA14459@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:53661 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477Ab2HIJxS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:53:18 -0400
In-Reply-To: <20120808133748.GA14459@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, Aug 08, 2012 at 05:36:05AM +0200, Arun MURTHY wrote:
> > > On Tue, Aug 07, 2012 at 12:24:28PM +0530, Arun Murthy wrote:
> > > > Adds Modem Access Framework, which allows for registering platform
> > > specific
> > > > modem access mechanisms. The framework also exposes APIs for
> > > > client
> > > drivers
> > > > for getting and releasing access to modem, regardless of the
> > > underlying
> > > > platform specific access mechanism.
> > >
> > > The term "modems" here has a lot of legacy connotations.  First of
> > > which is, userspace handles this today as tty devices, why aren't
> > > you doing the same here?  Why does this have to be something
> > > "special"?
> > >
> >
> > The main focus over there the modem IPC.
> 
> Over where?
> 
> What "modem IPC"?
> 

I mean the dir which is added in this patch, "modem_shm" is added to
have a separate list of such modem access drivers.

> You need to really explain what you are doing here, as I have no idea.
> And I have no idea why you still can't just use a tty device, why can't you?
> 


Its not that tty can be used or cant be used, but just to separate out the
modem related stuff in a separate folder.

> > In doing so, there are some functionality like waking the modem, or
> > releasing the modem etc. These will be used by the modem IPC drivers
> > and also few others like sim driver and security drivers.
> 
> What's a "sim driver", and what type of "security drivers" are you referring
> to?

SIM(Subscriber Identity Module) used in mobiles.
TEE(security) driver

> 
> > Since this is a shared call and hence has to be synchronized. Hence so
> > a small framework like is being done to monitor the modem access
> > related only operations.
> 
> Again, why can't the tty layer do this for you?
> 

Maybe tty can do this, but want to have all modem related  separately.
There are many such hardware and many drivers coming up in near future.

Thanks and Regards,
Arun R Murthy
-----------------
