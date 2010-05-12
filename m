From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/2] fixes to arp_notify for virtual machine migration use
 case
Date: Wed, 12 May 2010 14:39:14 +0100
Message-ID: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6162 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113Ab0ELNs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 09:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following 2 patches fix two issues with arp_notify, one is a niggle
and the other makes the feature work with virtual machine migration.

The following changes since commit 94b849aaf6e22ab7bf54b0d0377a882d4892396d:
  Linus Torvalds (1):
        Merge branch 'fix/hda' of git://git.kernel.org/.../tiwai/sound-2.6

are available in the git repository at:

  git://xenbits.xensource.com/people/ianc/linux-2.6.git for-netdev/fixes

Ian Campbell (2):
      arp_notify: generate broadcast ARP reply not request.
      arp_notify: generate arp_notify event on NETDEV_CHANGE too

 net/ipv4/devinet.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)


