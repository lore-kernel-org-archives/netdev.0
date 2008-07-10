From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 22:23:40 +0200
Message-ID: <200807102223.40717.borntraeger@de.ibm.com>
References: <4875428F.4080704@qualcomm.com> <200807101029.17121.borntraeger@de.ibm.com> <48763F94.7050507@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Brian Braunstein <linuxkernel@bristyle.com>,
	Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:57612 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbYGJUXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 16:23:52 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6AKNh3F243296
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 20:23:43 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6AKNhmN1175806
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 22:23:43 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6AKNgmq003845
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 22:23:42 +0200
In-Reply-To: <48763F94.7050507@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 10. Juli 2008 schrieb Max Krasnyansky:
> > Thing is, we are heading towards virtio. 
> Even for Windows ?

Its possible:
http://marc.info/?l=kvm&m=121075389300722&w=2

> 
> > Unfortunately, virtio_net currently  does not offer a method to register 
multicast addresses.
> I haven't looked at the virtio stuff much, I was assuming that the host side
> of it is still the TUN driver. Is it not ?

Yes, the host side is still tun/tap. The problem is that qemu doesnt know 
which multicast addresses are used inside the guest.

