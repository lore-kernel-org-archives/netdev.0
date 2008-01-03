From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 0/2] Labeled networking core stack changes for 2.6.25
Date: Thu, 03 Jan 2008 12:25:33 -0500
Message-ID: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:26374 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbYACRZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 12:25:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small patches for 2.6.25 which enable some new labeled networking features
and fixes.  One patch introduces a new outbound packet LSM hook and one adds
the skb 'iif' field to the list of fields copied during a clone operation.

Both of these patches are part of a much larger patchset that has been under
review on the SELinux and LSM mailing lists for the past few months (some bits
have been under review since this past spring).  I'll save everyone the spam
and not post the entire patchset here, but if you want to take a look you can
find the latest bits here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

I'm posting these patches here for review and hopefully an 'Acked-by', not
inclusion into net-2.6.25.  If these patches are acceptable then they will
pushed upstream with the rest of the changes when 2.6.25 is ready.

Thanks.

-- 
paul moore
linux security @ hp
