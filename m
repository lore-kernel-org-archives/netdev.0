From: Arun MURTHY <arun.murthy@stericsson.com>
Subject: RE: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Thu, 9 Aug 2012 12:14:03 +0200
Message-ID: <F45880696056844FA6A73F415B568C695B0E797057@EXDCVYMBSTM006.EQ1STM.local>
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
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On Wed, Aug 08, 2012 at 05:36:05AM +0200, Arun MURTHY wrote:
> > > > On Tue, Aug 07, 2012 at 12:24:28PM +0530, Arun Murthy wrote:
> > > > > Adds Modem Access Framework, which allows for registering
> > > > > platform
> > > > specific
> > > > > modem access mechanisms. The framework also exposes APIs for
> > > > > client
> > > > drivers
> > > > > for getting and releasing access to modem, regardless of the
> > > > underlying
> > > > > platform specific access mechanism.
> > > >
> > > > The term "modems" here has a lot of legacy connotations.  First of
> > > > which is, userspace handles this today as tty devices, why aren't
> > > > you doing the same here?  Why does this have to be something
> > > > "special"?
> > > >
> > >
> > > The main focus over there the modem IPC.
> >
> > Over where?
> >
> > What "modem IPC"?
> >
> 
> I mean the dir which is added in this patch, "modem_shm" is added to have a
> separate list of such modem access drivers.

The modem that I am referring to is an on chip modem in embedded platforms.
Applications of these being mobile, tablets etc.
So the APE and modem resides on a single chip.

Thanks and Regards,
Arun R Murthy
------------------
