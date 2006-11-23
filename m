From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Action 4 device ifb0 ifindex 7
Date: Thu, 23 Nov 2006 11:16:17 +0100
Message-ID: <BAY103-DAV1480D024D2786617F99E92B2E20@phx.gbl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s19.bay0.hotmail.com ([65.54.246.219]:53994 "EHLO
	bay0-omc3-s19.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1756727AbWKWKQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 05:16:26 -0500
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everybody.
I'm receiving this message:

Action 4 device ifb0 ifindex 7

when I issue this command:

tc filter add dev eth1 parent ffff: protocol ip prio 1 u32 \
match u32 0 0 action mirred egress redirect dev ifb0

I'm using linux 2.6.19-rc6 with tc version ss061002
Am I missing anything?


