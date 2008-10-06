From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Could you make vconfig less stupid?
Date: Mon, 6 Oct 2008 20:24:01 +0200
Message-ID: <20081006202401.14f03be2@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59415 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbYJFSYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 14:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vconfig prints bogus message, then autoloads the vlan module.
It is still living in 2.4 time warp.

# vconfig add dummy0 1
WARNING:  Could not open /proc/net/vlan/config.  Maybe you need to load the 8021q module, or maybe you are not using PROCFS??
Added VLAN with VID == 1 to IF -:dummy0:-

Other nuisance:
# vconfig --version
Expecting argc to be 3-5, inclusive.  Was: 2
...

1) users expect version
2) users don't expect argc related crap messages
