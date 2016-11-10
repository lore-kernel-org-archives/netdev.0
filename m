From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Thu, 10 Nov 2016 11:39:19 +0000
Message-ID: <E607265CB020454880711A6F96C05A03B677F4D9@hasmsx107.ger.corp.intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109160219.GB9111@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>,
        "Zhang, Xiong Y" <xiong.y.zhang@intel.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20161109160219.GB9111@kroah.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 9 2016, 06:02 PM, Greg KH wrote:
> On Wed, Nov 09, 2016 at 04:20:00PM +0200, Amir Levy wrote:
> > This driver enables Thunderbolt Networking on non-Apple platforms
> > running Linux.
> >
> > Thunderbolt Networking provides peer-to-peer connections to transfer
> > files between computers, perform PC migrations, and/or set up small
> > workgroups with shared storage.
> >
> > This is a virtual connection that emulates an Ethernet adapter that
> > enables Ethernet networking with the benefit of Thunderbolt superfast
> > medium capability.
> >
> > Thunderbolt Networking enables two hosts and several devices that have
> > a Thunderbolt controller to be connected together in a linear (Daisy
> > chain) series from a single port.
> >
> > Thunderbolt Networking for Linux is compatible with Thunderbolt
> > Networking on systems running macOS or Windows and also supports
> > Thunderbolt generation 2 and 3 controllers.
> >
> > Note that all pre-existing Thunderbolt generation 3 features, such as
> > USB, Display and other Thunderbolt device connectivity will continue
> > to function exactly as they did prior to enabling Thunderbolt Networking.
> >
> > Code and Software Specifications:
> > This kernel code creates a virtual ethernet device for computer to
> > computer communication over a Thunderbolt cable.
> > The new driver is a separate driver to the existing Thunderbolt driver.
> > It is designed to work on systems running Linux that interface with
> > Intel Connection Manager (ICM) firmware based Thunderbolt controllers
> > that support Thunderbolt Networking.
> > The kernel code operates in coordination with the Thunderbolt user-
> > space daemon to implement full Thunderbolt networking functionality.
> >
> > Hardware Specifications:
> > Thunderbolt Hardware specs have not yet been published but are used
> > where necessary for register definitions.
> >
> > Acked-by: Andreas Noever <andreas.noever@gmail.com>
> > Tested-by: Mario Limonciello <mario.limonciello@dell.com>
> 
> This whole series is acked and tested by these people?  If so, why did you not
> include that in each patch?
> 

Will add in next patch set.

> And how about getting some internal-Intel kernel developers to review and
> sign-off on this code?  Don't make the community do the review when you
> have access to resources like this.  You have an internal mailing list for this
> very purpose, use it!
> 

The review with the internal-Intel kernel developers was done before submitting
the first patch set.
Version 9 that we have here isn't so different from Version 0.

> thanks,
> 
> greg k-h
