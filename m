From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v5 1/2] PCI-Express Non-Transparent Bridge Support
Date: Thu, 15 Nov 2012 17:18:41 -0800
Message-ID: <20121116011841.GB32285@kroah.com>
References: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
 <1352160669-4330-2-git-send-email-jon.mason@intel.com>
 <20121116002904.GA20876@kroah.com>
 <20121116010621.GI24723@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121116010621.GI24723@jonmason-lab>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2012 at 06:06:21PM -0700, Jon Mason wrote:
> > > +static inline unsigned int ntb_query_max_cbs(struct ntb_device *ndev)
> > > +{
> > > +	return ndev->max_cbs;
> > > +}
> > 
> > It is shorter, and simpler, to just write the '->variable' version out
> > for this, than to make the function call here.  Why are these needed?
> > Especially when I see the driver code not using them.  Please remove.
> 
> This is used in ntb_transport.c.  It is used to show how many
> interrupts, and there-by clients, the transport layer can have.  I can
> make it a macro and/or put it in a header file, if that suits you
> better.

No, just reference the field of the structure directly, no need for a
function or a macro.

thanks,

greg k-h
