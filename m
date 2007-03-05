From: Matt Mackall <mpm@selenic.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 00:42:29 -0600
Message-ID: <20070305064229.GJ23311@waste.org>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752695AbXCEGzI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070305011625.GA7681@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2007 at 05:16:25PM -0800, Greg KH wrote:
> On Sun, Mar 04, 2007 at 04:08:57PM -0600, Matt Mackall wrote:
> > Recent kernels are having troubles with wireless for me. Two seemingly
> > related problems:
> > 
> > a) NetworkManager seems oblivious to the existence of my IPW2200
> > b) Manual iwconfig waits for 60s and then reports:
> > 
> > Error for wireless request "Set Encode" (8B2A) :
> >     SET failed on device eth1 ; Operation not supported.
> 
> Do you have CONFIG_SYSFS_DEPRECATED enabled?  If not, please do as that
> will keep you from having to change any userspace code.

No, it's disabled. Will test once I'm done tracking down the iwconfig
problem. From the help text for SYSFS_DEPRECATED:

          If you are using a distro that was released in 2006 or
	  later, it should be safe to say N here.

If we need an as-yet-unreleased HAL without it, I would say the above
should be changed to 2008 or so. If Debian actually cuts a release in
the next few months, you might make that 2010.

-- 
Mathematics is the supreme nostalgia of our time.
