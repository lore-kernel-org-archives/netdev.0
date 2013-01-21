From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH 08/21] NTB: declare unused variables
Date: Mon, 21 Jan 2013 10:50:55 -0700
Message-ID: <20130121175054.GE22208@jonmason-lab>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-9-git-send-email-jon.mason@intel.com>
 <20130120234228.GC14196@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130120234228.GC14196@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 20, 2013 at 03:42:28PM -0800, Greg KH wrote:
> On Sat, Jan 19, 2013 at 02:02:22AM -0700, Jon Mason wrote:
> > Tag pci_device_id in ntb_pci_probe as unused function parameters.  This
> > corrects issues found by 'EXTRA_CFLAGS=-W'.
> 
> Why would you build the kernel with that option?  This isn't needed, so

Per Documentation/SubmitChecklist:

22: Newly-added code has been compiled with `gcc -W' (use "make
    EXTRA_CFLAGS=-W").  This will generate lots of noise, but is good for
    finding bugs like "warning: comparison between signed and unsigned".


I was attempting to comply with that suggestion.  If this is
unnecessary, then I can toss these, but I don't really see them
hurting anything.

Same goes for the other 2 patches found via 'EXTRA_CFLAGS=-W'.

Thanks,
Jon

> I'm not going to apply it.
> 
> thanks,
> 
> greg k-h
