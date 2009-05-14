From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 21:28:57 +0930
Message-ID: <200905142128.58111.rusty@rustcorp.com.au>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55215 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755086AbZENL7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 07:59:16 -0400
In-Reply-To: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2009 07:37:42 pm Or Gerlitz wrote:
> Hi,
>
> When running with jumbo frames (i.e set tap0 and guest nic mtu to 9k)
> and using 8k sized packets with iperf, the qemu process exits with
> "virtio-net truncating packet" which I see in the code of
> qemu/hw/virtio-net.c
>
> :: virtio_net_receive(). This happens only when the VM is receiving, if I
>
> send 8K packets from the VM things go fine.
>
> I use virtio based NIC in the VM and Linux 2.6.29.1 in both the VM and the
> host. Qemu is the one provided by kvm release 84 - whose sources don't
> point me to a specific git tree nor a maintainer, so I hope you can help
> me...

Maintainer Cc'd.  The answer is that virtio_net by default only supports 1500 
MTU; I've not tried larger MTUs.

Rusty.
