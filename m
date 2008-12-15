From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 0/9] IrDA 2.6.28 bug fix
Date: Mon, 15 Dec 2008 02:57:29 +0100
Message-ID: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:46337 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751325AbYLOCDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a 9 patches series for IrDA, against your net-2.6 tree.
This is an attempt to fix kernel.bugzilla.org bug #11795, where we noticed
skb->cb could be altered once submitted to dev_queue_xmit. Since IrDA is using
this callback to pass per-skb information, we are now stuffing it in front of
skb->data, after allocating the right headroom.

Another solution would be to play with the IrDA physical header and skb_pull
our skbs whenever we are physically transmitting the data.

Cheers,
Samuel.
