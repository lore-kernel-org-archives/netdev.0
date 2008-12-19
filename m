From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 0/2][RESEND] netns: complete igmp per-netns
Date: Fri, 19 Dec 2008 15:25:05 +0100
Message-ID: <20081219142505.469589973@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33630 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbYLSO1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:27:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches where originally posted by Alexey Dobriyan in September.

They complete network namespaces support for IGMP:
* Allow IPPROTO_IGMP sockets
* Make igmp proc entries per-netns

One of the reasons I'm resending them is they are needed to benefit
from IPv4 multicast routing per-netns. Patchset coming soon.

They applies on top of net-next-2.6.

Regards,
Benjamin

