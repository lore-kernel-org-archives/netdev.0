From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 0/3] virtio_net GSO/partial csum fixes
Date: Tue, 27 May 2008 12:20:44 +0100
Message-ID: <1211887247-31979-1-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail03.svc.cra.dublin.eircom.net ([159.134.118.19]:41766 "HELO
	mail03.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756774AbYE0L1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 07:27:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,
        Here's a few virtio_net fixes related to partial csums
and GSO. These come about from playing with the tun/tap based
GSO patches you and Herbert posted earlier.

        3/3 is the signifcant one - I didn't actually reproduce
the problem with virtio_net, but rather observed it with the
tun/tap patch. In that case, packets which were sent by the
guest with a partial csum were ending up with an incorrect
csum when they were forwarded to a physical network.

Cheers,
Mark.


