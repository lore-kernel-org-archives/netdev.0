From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Wed, 4 May 2011 21:18:14 +0300
Message-ID: <20110504181813.GA17547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	herbert@gondor.hengli.com.au
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835Ab1EDSSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:18:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BTW, I just noticed that net-next spits out
many of the following when I run any VMs:

tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Features changed: 0x401b4849 -> 0x40004040
device msttap0 entered promiscuous mode
br0: Dropping NETIF_F_GSO since no SG feature.
br0: port 1(msttap0) entering forwarding state
br0: port 1(msttap0) entering forwarding state
tap0: Features changed: 0x40004040 -> 0x40024849
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Features changed: 0x40024849 -> 0x40004040
br0: Dropping NETIF_F_GSO since no SG feature.
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Features changed: 0x40004040 -> 0x401b4849
tap0: Dropping NETIF_F_SG since no checksum feature.
tap0: Dropping NETIF_F_GSO since no SG feature.
tap0: Features changed: 0x401b4849 -> 0x40004040
br0: Dropping NETIF_F_GSO since no SG feature.

My problem is not primarily with warnings:

will that linearize all packets and disable GSO
for tap and bridge? If yes it can't be good
for performance...

-- 
MST
