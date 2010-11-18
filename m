From: Clemens Ladisch <clemens@ladisch.de>
Subject: Re: [alsa-devel] sound playback became chopping on nfs rootfs
Date: Thu, 18 Nov 2010 10:03:36 +0100
Message-ID: <4CE4EBE8.8030702@ladisch.de>
References: <w3ptyjfrqde.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux-Net <netdev@vger.kernel.org>,
	Linux-ALSA <alsa-devel@alsa-project.org>
To: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:51070 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751412Ab0KRJBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 04:01:52 -0500
In-Reply-To: <w3ptyjfrqde.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kuninori Morimoto wrote:
> I noticed that sound playback became chopping on latest Linux kernel.
> ...
> This chopping seems happen from below patch.
> 
> 	commit 56463e50d1fc3f070492434cea6303b35ea000de
> 	Author: Chuck Lever <chuck.lever@oracle.com>
> 
> 	NFS: Use super.c for NFSROOT mount option parsing
>       ...
> 	Note that this means NFSROOT mounts now use the same default settings
> 	as v2/v3 mounts done via mount(2) from user space.

Apparently, the latest kernel uses different mount options.

Try to find out what mount options your root FS had in the old kernel,
and manually set them in some startup script.


Regards,
Clemens
