From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 21 May 2009 15:23:05 +0930
Message-ID: <200905211523.07278.rusty@rustcorp.com.au>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <200905201217.30939.rusty@rustcorp.com.au> <4A13A127.30305@voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Mark McLoughlin <markmc@redhat.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36536 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbZEUFxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 01:53:10 -0400
In-Reply-To: <4A13A127.30305@voltaire.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 May 2009 03:50:23 pm Or Gerlitz wrote:
> Rusty Russell wrote:
> > Bit 5 = VIRTIO_NET_F_MAC (the host set the mac address)
> > Bit 24 = VIRTIO_F_NOTIFY_ON_EMPTY
> > You don't have any GSO or checksum offload here
>
> Just to make sure I'm in the correct direction - I need to cause these
> offloads to be advertised by the "lower" part of virtio (e.g the qemu
> virtio code) to  the "upper" part (the quest kernel), correct? I
> understand that one of them is called front-end and the other back-end,
> but my intuitions don't go up to saying who's what...

Yes, that nomenclature is a bit weird.  I prefer "driver" (aka. guest, aka 
front-end) and "device" (aka. host, aka back-end).

All virtio_net drivers offer some features (at least CSUM offload), and 2.6.26 
and above will offer some serious GSO features.

Cheers,
Rusty.
