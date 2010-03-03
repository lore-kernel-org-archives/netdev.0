From: David Stevens <dlstevens@us.ibm.com>
Subject: [RFC][ PATCH 0/3] vhost-net: Add mergeable RX buffer support to vhost-net
Date: Tue, 2 Mar 2010 16:20:03 -0800
Message-ID: <OF8B8E9FD7.1F227ED3-ON882576DA.008312B5-882576DB.0001D5AB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: mst@redhat.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:40986 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635Ab0CCAUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 19:20:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add support for mergeable receive buffers to
vhost-net, allowing it to use multiple virtio buffer heads for a single
receive packet.
                                        +-DLS


Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
