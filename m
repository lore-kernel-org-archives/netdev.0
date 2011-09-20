From: David Miller <davem@redhat.com>
Subject: bridge carrier issue
Date: Tue, 20 Sep 2011 15:29:53 -0400 (EDT)
Message-ID: <20110920.152953.448244771460257273.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772Ab1ITT3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 15:29:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm marking the patches in patchwork on this as "deferred".

It is my opinion that we need to push back on the virtualization stuff
because otherwise it is impossible for network manager and friends to
operate properly.

Without the carrier going on only when a device is actually attached
and operating, NM has no "signal" to know when it actually should do
DHCP and whatnot.

On the other hand, the virtualization tools and libraries can operate
properly within the constraints added by the carrier behavior we have
now.

And I also believe they can do so in a way that allows them to work
on kernels before the carrier change.

Therefore, the only way to move forward and get everything working is
to change the virtualization tools.
