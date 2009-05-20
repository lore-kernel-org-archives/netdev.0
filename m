From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Wed, 20 May 2009 12:17:30 +0930
Message-ID: <200905201217.30939.rusty@rustcorp.com.au>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <200905151448.49851.rusty@rustcorp.com.au> <4A12A3B6.9020505@Voltaire.com>
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
Received: from ozlabs.org ([203.10.76.45]:60628 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023AbZETCrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 22:47:32 -0400
In-Reply-To: <4A12A3B6.9020505@Voltaire.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 May 2009 09:49:02 pm Or Gerlitz wrote:
> okay, this is the info from my guest after applying the patch on its
> kernel.
...
> [root@vm1 ~]# cat /sys/class/net/eth0/device/features
> 0000010000000000000000001000000000000000000000000000000000000000

Bit 5 = VIRTIO_NET_F_MAC (the host set the mac address)
Bit 24 = VIRTIO_F_NOTIFY_ON_EMPTY

You don't have any GSO or checksum offload here.

Rusty.

