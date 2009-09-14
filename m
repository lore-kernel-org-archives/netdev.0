From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 12:43:02 +0300
Message-ID: <4AAE1026.4090702@voltaire.com>
References: <20090910125929.GA32593@redhat.com>	<15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>	<20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com> <20090914091151.GE14030@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29030 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755017AbZINJm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 05:42:59 -0400
In-Reply-To: <20090914091151.GE14030@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:
> That's already possible. However virtualization users are familiar with configuring the tun device, and tun has grown virtualization-specific extensions, so I don't see a reason not to accomodate these uses
Today packets are written/read from/to Qemu to/from tun device, how 
would the use case with vhost will look like?

Is this the user setting an uplink NIC + bridge + per VM tun device but 
the packets will go from/to virtio-net in the guest kernel to/from vhost 
in the host kernel and then from/to vhost to/from tun? so eventually no 
packets will be seen by the qemu process? I don't see what these scheme 
buys people, I got very much confused.

Or.

