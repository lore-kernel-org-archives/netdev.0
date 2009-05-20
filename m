From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Wed, 20 May 2009 09:20:23 +0300
Message-ID: <4A13A127.30305@voltaire.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>	<200905151448.49851.rusty@rustcorp.com.au> <4A12A3B6.9020505@Voltaire.com> <200905201217.30939.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:20932 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752319AbZETGUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 02:20:32 -0400
In-Reply-To: <200905201217.30939.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> Bit 5 = VIRTIO_NET_F_MAC (the host set the mac address)
> Bit 24 = VIRTIO_F_NOTIFY_ON_EMPTY
> You don't have any GSO or checksum offload here
Just to make sure I'm in the correct direction - I need to cause these 
offloads to be advertised by the "lower" part of virtio (e.g the qemu 
virtio code) to  the "upper" part (the quest kernel), correct? I 
understand that one of them is called front-end and the other back-end, 
but my intuitions don't go up to saying who's what...

Or.


