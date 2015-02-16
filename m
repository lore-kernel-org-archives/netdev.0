From: Erik Hugne <erik.hugne@ericsson.com>
Subject: udp6_tunnel and address scope?
Date: Mon, 16 Feb 2015 10:38:34 +0100
Message-ID: <20150216093834.GB10236@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:59796 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479AbbBPJlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 04:41:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the ipv6 udp tunnel interface is missing scopeid. In a TIPC
patchset i'm working on, i worked around this by manually constructing the
sockaddr_in6 and binding this address to the v6 socket. But it may be worth
considering to add sin6_scopeid to struct udp_port_cfg.

//E 
