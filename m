From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 13:07:42 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:23252 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752580AbZENKHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 06:07:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When running with jumbo frames (i.e set tap0 and guest nic mtu to 9k)
and using 8k sized packets with iperf, the qemu process exits with
"virtio-net truncating packet" which I see in the code of qemu/hw/virtio-net.c
:: virtio_net_receive(). This happens only when the VM is receiving, if I
send 8K packets from the VM things go fine.

I use virtio based NIC in the VM and Linux 2.6.29.1 in both the VM and the host.
Qemu is the one provided by kvm release 84 - whose sources don't point me
to a specific git tree nor a maintainer, so I hope you can help me...

thanks,

Or.

