From: Pavel Emelianov <xemul@openvz.org>
Subject: [PATCH 0/2] Module for ip utility to support veth device (v.3)
Date: Thu, 12 Jul 2007 13:21:13 +0400
Message-ID: <4695F289.5000102@openvz.org>
References: <4695F0BF.1000305@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9671 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754530AbXGLJVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 05:21:22 -0400
In-Reply-To: <4695F0BF.1000305@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage is
# ip link add [name] type veth [peer <name>] [mac <mac>] [peer_mac <mac>]

This consists of two parts:
1/2 makes some copy-paste changes in ip/iplink.c for generic CLI
attributes parsing,
2/2 the module itself.

Signed-off-by: Pavel Emelianov <xemul@openvz.org>
