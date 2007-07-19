From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Module for ip utility to support veth device (v.3)
Date: Thu, 19 Jul 2007 13:30:24 +0400
Message-ID: <469F2F30.5080602@openvz.org>
References: <469F2DE7.9090407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:23914 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbXGSJag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 05:30:36 -0400
In-Reply-To: <469F2DE7.9090407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage is
# ip link add [name] type veth [device parameters] peer [name <name> <other device params>]

This consists of two parts:
1/2 makes some copy-paste changes in ip/iplink.c for generic CLI
attributes parsing,
2/2 the module itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Patrick McHardy <kaber@trash.net>
