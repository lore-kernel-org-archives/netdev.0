From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/4] virtio_net: Add MAC and VLAN filtering
Date: Tue, 03 Feb 2009 15:06:36 -0800 (PST)
Message-ID: <20090203.150636.175381174.davem@davemloft.net>
References: <20090203192550.2678.14498.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753523AbZBCXGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 18:06:39 -0500
In-Reply-To: <20090203192550.2678.14498.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 03 Feb 2009 12:25:50 -0700

> This series adds infrastructure for a new control virtqueue and
> makes use of it to support set_rx_mode, unicast and multicast address
> lists, and supporting a hypervisor based VLAN filter.  The goal is to
> make the virtio-net device support more of the features of a physical
> NIC and allow the hypervisor to discard packets we don't want.  These
> patches are intended for 2.6.30.
> 
> This is the 4th and hopefully final revision, incorporating a few
> more tweaks from Rusty.

The second patch doesn't apply to the net-next-2.6 tree.

Please regenerate these against net-next-2.6 or -next and
I'll apply them, thanks.
