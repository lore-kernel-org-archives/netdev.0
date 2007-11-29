From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [0/12] pasemi_mac updates for 2.6.25 + DMA channel
	management library
Date: Wed, 28 Nov 2007 20:54:10 -0600
Message-ID: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:39619 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753560AbXK2Cu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:50:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following series contains driver updates for 2.6.25, together with a
couple of patches that introduces a library for abstracting DMA channel
allocation and access.

While the DMA stuff (patches 5 and 6) isn't really netdev material, the
driver updates depend on them, and it'd just be easier to merge them up
the netdev path.

The patches are:

1/12: pasemi_mac: RX/TX ring management cleanup
2/12: pasemi_mac: Remove SKB copy/recycle logic
3/12: pasemi_mac: Print warning when not attaching to a PHY
4/12: pasemi_mac: Don't enable RX/TX without a link (if possible)
5/12: pasemi_mac: Move register definitions to include/asm-powerpc
6/12: pasemi: DMA engine management library
7/12: pasemi_mac: Convert to new dma library
8/12: pasemi_mac: performance tweaks
9/12: pasemi_mac: Fix TX cleaning
10/12: pasemi_mac: Improve RX interrupt mitigation
l1/12: pasemi_mac: Software-based LRO support
12/12: pasemi_mac: SKB unmap optimization



-Olof
