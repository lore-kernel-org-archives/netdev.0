From: Matt Mackall <mpm@selenic.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 13:55:30 -0600
Message-ID: <20070305195530.GM23311@waste.org>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org> <20070305185813.GA31465@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Theodore Tso <tytso@mit.edu>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:35683 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbXCEUIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 15:08:31 -0500
Content-Disposition: inline
In-Reply-To: <20070305185813.GA31465@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 10:58:13AM -0800, Greg KH wrote:
> Ok, how about the following patch.  Is it acceptable to everyone?
> 
> -	  If you are using a distro that was released in 2006 or later,
> -	  it should be safe to say N here.
> +	  If you are using an OpenSuSE, Gentoo, Ubuntu, or Fedora
> +	  release from 2007 or later, it should be safe to say N here.
> +
> +	  If you are using Debian or other distros that are slow to
> +	  update HAL, please say Y here.

What HAL version do you think Debian ought to have, pray tell? And
what the hell version do those other distros have?

The last HAL release was 0.5.8 on 11-Sep-2006. It showed up in
Debian/unstable on 2-Oct. There have been six Debian bugfix releases,
the most recent on 12-Feb.

http://people.freedesktop.org/~david/dist/
http://packages.debian.org/changelogs/pool/main/h/hal/hal_0.5.8.1-6.1/changelog

The last NetworkManager is 0.6.4 released 13-Jul-2006. It showed up in
Debian/unstable on 8-Aug. There have been five bugfix releases, the
most recent on 30-Nov.

http://ftp.gnome.org/pub/GNOME/sources/NetworkManager/0.6/
http://packages.debian.org/changelogs/pool/main/n/network-manager/network-manager_0.6.4-6/changelog

Debian is NOT the problem.

-- 
Mathematics is the supreme nostalgia of our time.
