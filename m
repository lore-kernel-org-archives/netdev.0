From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Tue, 09 Dec 2008 15:32:14 -0600
Message-ID: <493EE3DE.7080702@codemonkey.ws>
References: <1228817973.26198.1.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:53799 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbYLIVcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 16:32:21 -0500
Received: by nf-out-0910.google.com with SMTP id d3so43883nfc.21
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 13:32:19 -0800 (PST)
In-Reply-To: <1228817973.26198.1.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> Allow the host to inform us that the link is down by adding
> a VIRTIO_NET_F_STATUS which indicates that device status is
> available in virtio_net config.
> 
> This is currently useful for simulating link down conditions
> (e.g. using proposed qemu 'set_link' monitor command) but
> would also be needed if we were to support device assignment
> via virtio.

It would be nice if the virtio-net card wrote some acknowledgement that 
it has received the link status down/up events.

I'm thinking along the lines of doing live migration between two end 
points that are not on the same subnet.  It would be nice to be able to 
signal link status down, have the guest acknowledge that it received it, 
do the live migration, then do link status up so the guest reconnects 
it's networking.

Regards,

Anthony Liguori
