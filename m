From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] virtio_net: Add MAC and VLAN filtering
Date: Wed, 04 Feb 2009 16:35:45 -0800 (PST)
Message-ID: <20090204.163545.31569169.davem@davemloft.net>
References: <20090203.150636.175381174.davem@davemloft.net>
	<20090204190229.2512.93552.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090204190229.2512.93552.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 04 Feb 2009 12:02:29 -0700

> This series adds infrastructure for a new control virtqueue and
> makes use of it to support set_rx_mode, unicast and multicast address
> lists, and supporting a hypervisor based VLAN filter.  The goal is to
> make the virtio-net device support more of the features of a physical
> NIC and allow the hypervisor to discard packets we don't want.  These
> patches are intended for 2.6.30.
> 
> This version is just a rebase to current net-next-2.6.git.  I'll send
> Rusty an update to the patch in his queue that led to the patch
> conflict, this series doesn't depend on it.

All applied to net-next-2.6, thanks everyone!
