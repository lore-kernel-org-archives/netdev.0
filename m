From: Theodore Tso <tytso@mit.edu>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 07:59:50 -0500
Message-ID: <20070305125950.GC26781@thunk.org>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:51558 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933429AbXCENAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 08:00:09 -0500
Content-Disposition: inline
In-Reply-To: <20070305011729.GB7681@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2007 at 05:17:29PM -0800, Greg KH wrote:
> I should not have broken any userspace if CONFIG_SYSFS_DEPRECATED is
> enabled with that patch.  If that is enabled, and that patch still
> causes problems, please let me know.

But we still need to update the help text for CONFIG_SYS_DEPRECATED to
make it clear that its deprecation schedule still needs to be 2009 to
2011 (depending on whether we want to accomodate Debian's glacial
release schedule).  Certainly the 2006 date which is currently there
simply isn't accurate.

						- Ted
