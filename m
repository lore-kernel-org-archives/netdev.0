From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Sun, 15 Jul 2012 17:19:21 -0700
Message-ID: <20120716001921.GA19775@kroah.com>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
 <20120714171015.GB25775@kroah.com>
 <20120715235548.GC7551@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120715235548.GC7551@jonmason-lab>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 15, 2012 at 04:55:48PM -0700, Jon Mason wrote:
> On Sat, Jul 14, 2012 at 10:10:15AM -0700, Greg KH wrote:
> > On Fri, Jul 13, 2012 at 02:44:59PM -0700, Jon Mason wrote:
> > > +static int max_num_cbs = 2;
> > > +module_param(max_num_cbs, uint, 0644);
> > > +MODULE_PARM_DESC(max_num_cbs, "Maximum number of NTB transport connections");
> > > +
> > > +static bool no_msix;
> > > +module_param(no_msix, bool, 0644);
> > > +MODULE_PARM_DESC(no_msix, "Do not allow MSI-X interrupts to be selected");
> > 
> > How would a user, or a distro, know to set these options?  Why are they
> > even options at all?
> 
> Good question.  There is actually a potential benefit to disabling
> MSI-X.  The NTB device on one of our platforms only has 3 MSI-X
> vectors.  In the current driver design, that would limit them to 3
> client/virtual devices.  However, there are 15bits in the ISR that can
> be used for the same purpose.  So, if you disable MSI-X, you can have
> 15 instead of 3.  

But again, how would a user, or a distro, know to set these?  Where is
the documentation describing it?  Why really have these options at all
and not just fix the platform issues (only 3 MSI-X vectors?  Really?)

thanks,

greg k-h
