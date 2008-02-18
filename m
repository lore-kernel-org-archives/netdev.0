From: Ferenc Wagner <wferi@niif.hu>
Subject: ipv6 debugging
Date: Mon, 18 Feb 2008 15:06:19 +0100
Message-ID: <87zltyjr50.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:57467 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382AbYBROiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 09:38:51 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.63)
	(envelope-from <wferi@niif.hu>)
	id 1JR6dP-0007Zp-47
	for netdev@vger.kernel.org; Mon, 18 Feb 2008 15:06:19 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm kindly asking for some debugging tips with the following problem:
a machine is running Linux 2.6.24.2, several 802.1q VLAN-s over
active/backup bonding over two physical interfaces.  Everything is
allright, except for after a reboot, there's no IPv6, while IPv4
works.  The router's ARP(6) table is empty, the machine doesn't answer
ping6.  However, if I start tcpdump -i bond0 ip6, everything is
allright again.  There are some indications that after some period
without IPv6 traffic, the same can happen again.  Are there known
issues which can exhibit themselves like this?  Other very similar
setups don't show this erratic behaviour.

I know that the above doesn't give a fully detailed picture, but
thought that I'd better ask before taking the setup into pieces.
-- 
Thanks for your thoughts,
Feri.
