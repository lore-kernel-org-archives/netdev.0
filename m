From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/9]: Killing qdisc->ops->requeue().
Date: Mon, 18 Aug 2008 01:36:40 -0700 (PDT)
Message-ID: <20080818.013640.254202527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750924AbYHRIgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:36:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This implements what I tried to describe in previous
emails.

It gets rid of qdisc->ops->requeue() because logically it
is completely superfluous.  All it does is allow the
next level to declare to the lower qdisc "send this next
no matter what" and we can trivially do that with a simple
list.

Signed-off-by: David S. Miller <davem@davemloft.net>
