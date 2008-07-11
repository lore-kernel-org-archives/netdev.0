From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 19:20:07 -0700
Message-ID: <4876C357.3030708@qualcomm.com>
References: <4875428F.4080704@qualcomm.com> <200807101029.17121.borntraeger@de.ibm.com> <48763F94.7050507@qualcomm.com> <200807102223.40717.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Brian Braunstein <linuxkernel@bristyle.com>,
	Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:62245 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbYGKCUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 22:20:08 -0400
In-Reply-To: <200807102223.40717.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Christian Borntraeger wrote:
> Am Donnerstag, 10. Juli 2008 schrieb Max Krasnyansky:
>>> Thing is, we are heading towards virtio. 
>> Even for Windows ?
> 
> Its possible:
> http://marc.info/?l=kvm&m=121075389300722&w=2
Nice.
btw Is there something similar for the display driver ? vmware has one.

>>> Unfortunately, virtio_net currently  does not offer a method to register 
> multicast addresses.
>> I haven't looked at the virtio stuff much, I was assuming that the host side
>> of it is still the TUN driver. Is it not ?
> 
> Yes, the host side is still tun/tap. The problem is that qemu doesnt know 
> which multicast addresses are used inside the guest.
Ah, now I see what you meant by virtio_net does not do multicast. I guess it
should trivial to add. Rusty will clarify it I guess.

Max

