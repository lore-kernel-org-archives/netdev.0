From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH iproute2 0/2] Modify iproute2 to display neighbour proxies
Date: Thu, 26 Jan 2012 18:50:03 +0400
Message-ID: <1327589405-10930-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------true"
Cc: <devel@openvz.org>, Tony Zelenoff <antonz@parallels.com>,
	<kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>
To: <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:45103 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab2AZOuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 09:50:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------true
Content-Type: text/plain; charset="UTF-8"; format=fixed
Content-Transfer-Encoding: 8bit

This modification use new kernel functionality to display
neighbour proxies.

Old kernel versions will work nice in case the 'family' member
has the same place and size in rtgenmsg and ndmsg structures.
Also kernel did not check size of incoming structure.

Tony Zelenoff (2):
  Modify neighbour show according to new kernel ability
  Adjust man page for new functionality

 ip/ipneigh.c            |   12 ++++++++++--
 man/man8/ip-neighbour.8 |    6 +++++-
 2 files changed, 15 insertions(+), 3 deletions(-)


--------------true--
