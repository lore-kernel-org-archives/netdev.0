From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/5] macvtap fixes.
Date: Thu, 20 Oct 2011 07:24:59 -0700
Message-ID: <m1wrbzu4ec.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57567 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab1JTOYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:24:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series of patches fixes a series of minor bugs in the macvtap code.

The fixes to handle failures in newlink and the change in how we handle
minor device number allocations are particularly significant.

Eric W. Biederman (5):
      macvtap: Close a race between macvtap_open and macvtap_dellink.
      macvtap: Fix macvtap_open races in the zero copy enable code.
      macvtap: Don't leak unreceived packets when we delete a macvtap device.
      macvtap: Rewrite macvtap_newlink so the error handling works.
      macvtap: Fix the minor device number allocation
