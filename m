From: Steven Whitehouse <swhiteho@redhat.com>
Subject: My 802.3ad is my bond
Date: Wed, 23 Jan 2008 15:45:00 +0000
Message-ID: <1201103100.22038.254.camel@quoit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793AbYAWQBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 11:01:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This commit: ece95f7fefe3afae19e641e1b3f5e64b00d5b948 seems to have
caused a problem with parsing bond arguments as now only the numeric
arguments seem to work (in modprobe.conf) and specifying 802.3ad fails.
When I revert that patch in my local tree all seems ok.

Also I notice that one of my two NICs now reports this:

bonding: bond0: link status definitely down for interface eth0,
disabling it
bonding: bond0: Interface eth0 is already enslaved!
bond0.5: no IPv6 routers present

which I think is also new with this set of bonding updates, before it
used to use both interfaces ok. I've not worked out which of the other
patches causes this so far, but I can if its helpful,

Steve.


