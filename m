From: Jiri Pirko <jpirko@redhat.com>
Subject: [question] bridged tunnel
Date: Tue, 28 Jul 2009 09:59:29 +0200
Message-ID: <20090728075928.GB3633@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37232 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbZG1H71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 03:59:27 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6S7xRps011953
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 03:59:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.

Imagine following net scheme:

LAN1 --- ROUTER A --- ROUTER B --- LAN2

I would like to have LAN1 and LAN2 bridged together.

I'm wondering if it's possible to made a tunnel and put it in bridge in
kernel space only? I would do the same with TAP and some dummy userspace
client/server but this would obviously decrease performance. Is it reasonable to
try to modify tun driver to be used not only via chardev but also via some
kernel API? This API would be used for other kernel modules to actually do the
communication.

Thanks for comments.

Jirka
