From: Vincent Bernat <bernat@luffy.cx>
Subject: nonlocal_bind and IPv6
Date: Mon, 12 Dec 2011 14:18:42 +0100
Message-ID: <1323695923-23849-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:44150 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752989Ab1LLN1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 08:27:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

It is possible with IPv4 to set net.ipv4.ip_nonlocal_bind to 1 and to
bind to non local addresses. This patch adds the same possibility for
IPv6. Since the IPv4 version is not constrained to a network
namespace, I have followed the same approach for the IPv6
version.
