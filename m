From: Tomasz Torcz <zdzichu@irc.pl>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 16:46:09 +0100
Message-ID: <20070305154609.GA3626@irc.pl>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg@kroah.com, netdev@vger.kernel.org, yi.zhu@intel.com,
	jketreno@linux.intel.com, akpm@osdl.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nsm.pl ([195.34.211.229]:50513 "EHLO nsm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933563AbXCEP5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:57:10 -0500
Received: from localhost (localhost [127.0.0.1])
	by nsm.pl (Postfix) with ESMTP id 2208DD794F
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:17 +0100 (CET)
Received: from nsm.pl ([195.34.211.229])
	by localhost (nsm.pl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id phKsnzI-bwfc for <netdev@vger.kernel.org>;
	Mon,  5 Mar 2007 16:46:11 +0100 (CET)
Received: from matthew.ogrody.nsm.pl (unknown [10.10.174.98])
	by nsm.pl (Postfix) with SMTP id 8FF1FD7951
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:07 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070305071325.GK23311@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 01:13:26AM -0600, Matt Mackall wrote:
> On Sun, Mar 04, 2007 at 11:02:48PM -0800, Greg KH wrote:
> > On Mon, Mar 05, 2007 at 12:42:29AM -0600, Matt Mackall wrote:
> > > On Sun, Mar 04, 2007 at 05:16:25PM -0800, Greg KH wrote:
> > > > On Sun, Mar 04, 2007 at 04:08:57PM -0600, Matt Mackall wrote:
> > > > > Recent kernels are having troubles with wireless for me. Two seemingly
> > > > > related problems:
> > > > > 
> > > > > a) NetworkManager seems oblivious to the existence of my IPW2200
> > > > > b) Manual iwconfig waits for 60s and then reports:
> > > > > 
> > > > > Error for wireless request "Set Encode" (8B2A) :
> > > > >     SET failed on device eth1 ; Operation not supported.
> > > > 
> > > > Do you have CONFIG_SYSFS_DEPRECATED enabled?  If not, please do as that
> > > > will keep you from having to change any userspace code.
> > > 
> > > No, it's disabled. Will test once I'm done tracking down the iwconfig
> > > problem. From the help text for SYSFS_DEPRECATED:
> > > 
> > >           If you are using a distro that was released in 2006 or
> > > 	  later, it should be safe to say N here.
> > > 
> > > If we need an as-yet-unreleased HAL without it, I would say the above
> > > should be changed to 2008 or so. If Debian actually cuts a release in
> > > the next few months, you might make that 2010.
> > 
> > Well, just because Debian has such a slow release cycle, should the rest
> > of the world be forced to follow suit?  :)
> > 
> > When I originally wrote that, I thought Debian would have already done
> > their release, my mistake...
> 
> That's not the point. The point is that Debian/unstable as of _this
> morning_ doesn't work. For reference, I'm running both the latest
> releases of both hal (0.5.8.1-6.1) and network-manager (0.6.4-6). And
> there are people telling me I need a copy of HAL out of git that
> hasn't even been released for Debian to package. Debian isn't the
> problem here.

  hal 0.5.9-rc1 (released, not from git) should work. It will be
problably released soon and picked by sane distributions. Debian is very
irritating corner case.

-- 
Tomasz Torcz                Only gods can safely risk perfection,
zdzichu@irc.-nie.spam-.pl     it's a dangerous thing for a man.  -- Alia

