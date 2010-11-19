From: Clemens Ladisch <clemens@ladisch.de>
Subject: Re: [alsa-devel] sound playback became chopping on nfs rootfs
Date: Fri, 19 Nov 2010 09:15:11 +0100
Message-ID: <4CE6320F.6060600@ladisch.de>
References: <w3ptyjfrqde.wl%kuninori.morimoto.gx@renesas.com>	<4CE4EBE8.8030702@ladisch.de> <w3p39qx4ty8.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux-Net <netdev@vger.kernel.org>,
	Linux-ALSA <alsa-devel@alsa-project.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:32991 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887Ab0KSINa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 03:13:30 -0500
In-Reply-To: <w3p39qx4ty8.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kuninori Morimoto wrote:
> > Apparently, the latest kernel uses different mount options.
> > 
> > Try to find out what mount options your root FS had in the old kernel,
> > and manually set them in some startup script.
> 
> OK. Thanks. I try it.
> Does this "mount options" mean root_mountflags ?

No; the defaults for options that are not set in root_mountflags
have changed.

Try /proc/mounts.


Regards,
Clemens
