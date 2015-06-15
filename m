From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 0/2] iplink_geneve: add ttl and tos configuration bits
Date: Mon, 15 Jun 2015 14:37:14 -0400
Message-ID: <1434393436-4487-1-git-send-email-linville@tuxdriver.com>
References: <1432320406-28121-1-git-send-email-linville@tuxdriver.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52596 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbbFOSh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 14:37:58 -0400
In-Reply-To: <1432320406-28121-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pair of patches add configuration of TTL and TOS settings for
GENEVE tunnel packets.  These settings follow the same conventions
as the VXLAN counterparts.

These patches include man page changes.  Therefore, they depend on
the preceding "iproute2: update ip-link.8 for geneve tunnels" patch,
posted to netdev on 22 May 2015.

Thanks,

John
