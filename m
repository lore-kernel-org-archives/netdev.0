From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH v4 0/4] virtio_net: Add MAC and VLAN filtering
Date: Tue, 03 Feb 2009 16:42:57 -0700
Message-ID: <1233704577.25178.55.camel@bling>
References: <20090203192550.2678.14498.stgit@debian.lart>
	 <20090203.150636.175381174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090203.150636.175381174.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-02-03 at 15:06 -0800, David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Tue, 03 Feb 2009 12:25:50 -0700
> 
> > This series adds infrastructure for a new control virtqueue and
> > makes use of it to support set_rx_mode, unicast and multicast address
> > lists, and supporting a hypervisor based VLAN filter.  The goal is to
> > make the virtio-net device support more of the features of a physical
> > NIC and allow the hypervisor to discard packets we don't want.  These
> > patches are intended for 2.6.30.
> > 
> > This is the 4th and hopefully final revision, incorporating a few
> > more tweaks from Rusty.
> 
> The second patch doesn't apply to the net-next-2.6 tree.
> 
> Please regenerate these against net-next-2.6 or -next and
> I'll apply them, thanks.

Ack, sorry.  I had dropped the original first patch that allows setting
the virtio_net MAC address since Rusty already accepted it into his
patch queue.  I can easily munge these to not rely on that (context-only
changes), but that'll just leave Rusty with the merge conflict.  Rusty,
which way do you want these to hit the tree?  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

