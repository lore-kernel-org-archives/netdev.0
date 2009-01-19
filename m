From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] virtio_net: Add MAC and VLAN filtering
Date: Sun, 18 Jan 2009 22:05:28 -0800 (PST)
Message-ID: <20090118.220528.02874092.davem@davemloft.net>
References: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, markmc@redhat.com,
	kvm@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755774AbZASGF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:05:27 -0500
In-Reply-To: <20090116211312.22836.34331.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 16 Jan 2009 14:13:12 -0700

> This series enables setting the virtio-net device MAC address, adds
> infrastructure for the new control virtqueue, and makes use of it
> to support set_rx_mode, unicast and multicast address lists, and
> supporting a hypervisor based VLAN filter.  The goal is to make the
> virtio-net device support more of the features of a physical NIC and
> allow the hypervisor to discard packets we're not interested in.
> 
> This version incorporates the review comments from Mark McLoughlin,
> specifically, much improved comments and commit logs, verifying the
> functionality of host not providing a MAC address, moving communication
> structs into virtio_net.h, adding warnings when things don't work, and
> making the strings grep'able.  I've left the class/cmd split in the
> control header rather than consolidating it into a single value, I'm
> hoping I've made sufficient arguments for that.  Also, I left the
> error return rather than a BUG_ON in send_command because I can't
> conditionally enable set_rx_mode as it's in a const struct.  Instead,
> I've changed the caller to avoid the issue.  Please comment and/or
> apply.  Thanks,

I've been watching these patches passively, and it seems that
there have been some comments that Rusty hasn't submitted
certain virtio_net patches to me as well.

Please sort this all out and let me know what to queue up for
2.6.30

Thanks.
