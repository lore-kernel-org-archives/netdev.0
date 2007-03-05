From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 10:58:13 -0800
Message-ID: <20070305185813.GA31465@kroah.com>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Theodore Tso <tytso@mit.edu>, Matt Mackall <mpm@selenic.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:47485 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932213AbXCES7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 13:59:03 -0500
Content-Disposition: inline
In-Reply-To: <20070305125950.GC26781@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 07:59:50AM -0500, Theodore Tso wrote:
> On Sun, Mar 04, 2007 at 05:17:29PM -0800, Greg KH wrote:
> > I should not have broken any userspace if CONFIG_SYSFS_DEPRECATED is
> > enabled with that patch.  If that is enabled, and that patch still
> > causes problems, please let me know.
> 
> But we still need to update the help text for CONFIG_SYS_DEPRECATED to
> make it clear that its deprecation schedule still needs to be 2009 to
> 2011 (depending on whether we want to accomodate Debian's glacial
> release schedule).  Certainly the 2006 date which is currently there
> simply isn't accurate.

Ok, how about the following patch.  Is it acceptable to everyone?

thanks,

greg k-h

---
 init/Kconfig |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

--- gregkh-2.6.orig/init/Kconfig
+++ gregkh-2.6/init/Kconfig
@@ -290,8 +290,17 @@ config SYSFS_DEPRECATED
 	  that belong to a class, back into the /sys/class heirachy, in
 	  order to support older versions of udev.
 
-	  If you are using a distro that was released in 2006 or later,
-	  it should be safe to say N here.
+	  If you are using an OpenSuSE, Gentoo, Ubuntu, or Fedora
+	  release from 2007 or later, it should be safe to say N here.
+
+	  If you are using Debian or other distros that are slow to
+	  update HAL, please say Y here.
+
+	  If you have any problems with devices not being found properly
+	  from userspace programs, and this option is disabled, say Y
+	  here.
+
+	  If you are unsure about this at all, say Y.
 
 config RELAY
 	bool "Kernel->user space relay support (formerly relayfs)"
