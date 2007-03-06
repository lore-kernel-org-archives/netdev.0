From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 17:08:49 -0800
Message-ID: <20070305170849.c042e802.akpm@linux-foundation.org>
References: <20070304220857.GH23311@waste.org>
	<20070305011625.GA7681@kroah.com>
	<20070305064229.GJ23311@waste.org>
	<20070305070248.GA30699@kroah.com>
	<20070305071325.GK23311@waste.org>
	<20070305154609.GA3626@irc.pl>
	<20070305211425.GR16722@waste.org>
	<20070306002457.GA7078@brong.net>
	<20070306003715.GA12566@kroah.com>
	<20070306005625.GC19634@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Bron Gondwana <brong@fastmail.fm>,
	Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com
To: Theodore Tso <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44196 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933707AbXCFBJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 20:09:11 -0500
In-Reply-To: <20070306005625.GC19634@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007 19:56:25 -0500
Theodore Tso <tytso@mit.edu> wrote:

> So the question really is are we really done making changes to sysfs,
> or maybe what we should do is talk about major version numbers to
> sysfs.

Perhaps using a config option wasn't the right way to do this - a kernel
boot parameter might be better.

In fact, one could envisage a kernel boot parameter "sysfs_version=N" which 
will allow distro people to select the sysfs-of-the-day which works with their
userspace.

Because it does appear that we need _something_ which will get us away from this
ongoing problem of needing to keep the kernel and userspace synchronised across
sysfs changes.
