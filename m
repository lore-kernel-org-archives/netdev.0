From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Wed, 9 Nov 2016 17:02:19 +0100
Message-ID: <20161109160219.GB9111@kroah.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 09, 2016 at 04:20:00PM +0200, Amir Levy wrote:
> This driver enables Thunderbolt Networking on non-Apple platforms
> running Linux.
> 
> Thunderbolt Networking provides peer-to-peer connections to transfer
> files between computers, perform PC migrations, and/or set up small
> workgroups with shared storage.
> 
> This is a virtual connection that emulates an Ethernet adapter that
> enables Ethernet networking with the benefit of Thunderbolt superfast
> medium capability.
> 
> Thunderbolt Networking enables two hosts and several devices that
> have a Thunderbolt controller to be connected together in a linear
> (Daisy chain) series from a single port.
> 
> Thunderbolt Networking for Linux is compatible with Thunderbolt
> Networking on systems running macOS or Windows and also supports
> Thunderbolt generation 2 and 3 controllers.
> 
> Note that all pre-existing Thunderbolt generation 3 features, such as
> USB, Display and other Thunderbolt device connectivity will continue
> to function exactly as they did prior to enabling Thunderbolt Networking.
> 
> Code and Software Specifications:
> This kernel code creates a virtual ethernet device for computer to
> computer communication over a Thunderbolt cable.
> The new driver is a separate driver to the existing Thunderbolt driver.
> It is designed to work on systems running Linux that
> interface with Intel Connection Manager (ICM) firmware based
> Thunderbolt controllers that support Thunderbolt Networking.
> The kernel code operates in coordination with the Thunderbolt user-
> space daemon to implement full Thunderbolt networking functionality.
> 
> Hardware Specifications:
> Thunderbolt Hardware specs have not yet been published but are used
> where necessary for register definitions. 
> 
> Acked-by: Andreas Noever <andreas.noever@gmail.com>
> Tested-by: Mario Limonciello <mario.limonciello@dell.com>

This whole series is acked and tested by these people?  If so, why did
you not include that in each patch?

And how about getting some internal-Intel kernel developers to review
and sign-off on this code?  Don't make the community do the review when
you have access to resources like this.  You have an internal mailing
list for this very purpose, use it!

thanks,

greg k-h
