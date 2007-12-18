From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] Module for ip utility to support veth device (v.4)
Date: Tue, 18 Dec 2007 15:14:33 +0300
Message-ID: <200712181514.34060.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4349 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbXLRMMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 07:12:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage is
# ip link add [name]  [device parameters] type veth [peer [name <name> <other 
device params>]]

This consists of two parts:
1/2 makes some copy-paste changes in ip/iplink.c for generic CLI
attributes parsing,
2/2 the module itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

