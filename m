From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to
	start_udev
Date: Wed, 3 Nov 2010 11:05:00 -0700
Message-ID: <20101103180500.GA7441@kroah.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Matt_Domsch@Dell.com, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:54565 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab0KCSP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 14:15:59 -0400
Content-Disposition: inline
In-Reply-To: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 10:25:25PM +0530, Narendra_K@Dell.com wrote:
> Hello,
> 
> This patch allows users to specify if they want the onboard network
> interfaces to be renamed to lomN by implementing a command line param
> 'udevlom'.

Ick ick ick.

Why not do this in some other configuration file?  Don't rely on udev
being started with a different option, that is only ripe for abuse by
everyone else who wants their pet-project to get into the udev
environment.

Please, surely there's a different way to do this.

thanks,

greg k-h
