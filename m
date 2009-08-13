From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 15:48:35 +0200
Message-ID: <200908131548.35199.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <20090813060615.GC3029@redhat.com> <200908131538.44465.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58624 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbZHMNtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 09:49:49 -0400
In-Reply-To: <200908131538.44465.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 13 August 2009, Arnd Bergmann wrote:
> Unfortunately, this also implies that you could no longer simply use the
> packet socket interface as you do currently, as I realized only now.
> This obviously has a significant impact on your user space interface.

Also, if we do the copy in the transport, it definitely means that we
can't get to zero-copy RX/TX from guest space any more. The current
vhost_net driver doesn't do that yet, but could be extended in the
same way that I'm hoping to do it for macvtap.

	Arnd <><
