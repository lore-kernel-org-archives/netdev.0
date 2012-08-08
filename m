From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Wed, 8 Aug 2012 06:37:48 -0700
Message-ID: <20120808133748.GA14459@kroah.com>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
 <1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
 <20120807183809.GC26990@kroah.com>
 <F45880696056844FA6A73F415B568C695B0E796A03@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F45880696056844FA6A73F415B568C695B0E796A03@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2012 at 05:36:05AM +0200, Arun MURTHY wrote:
> > On Tue, Aug 07, 2012 at 12:24:28PM +0530, Arun Murthy wrote:
> > > Adds Modem Access Framework, which allows for registering platform
> > specific
> > > modem access mechanisms. The framework also exposes APIs for client
> > drivers
> > > for getting and releasing access to modem, regardless of the
> > underlying
> > > platform specific access mechanism.
> > 
> > The term "modems" here has a lot of legacy connotations.  First of
> > which
> > is, userspace handles this today as tty devices, why aren't you doing
> > the same here?  Why does this have to be something "special"?
> > 
> 
> The main focus over there the modem IPC.

Over where?

What "modem IPC"?

You need to really explain what you are doing here, as I have no idea.
And I have no idea why you still can't just use a tty device, why can't
you?

> In doing so, there are some functionality like waking the modem, or
> releasing the modem etc. These will be used by the modem IPC drivers
> and also few others like sim driver and security drivers.

What's a "sim driver", and what type of "security drivers" are you
referring to?

> Since this is a shared call and hence has to be synchronized. Hence so a
> small framework like is being done to monitor the modem access related only
> operations.

Again, why can't the tty layer do this for you?

greg k-h
