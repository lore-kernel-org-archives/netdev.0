From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 0/1] Allow to monitor protocol configuration
Date: Tue, 23 Oct 2012 11:49:46 +0200
Message-ID: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60955 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab2JWJly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 05:41:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie aims to advertising via netlink any change in the network
configuration of a protocol (network or transport). For example the announcement
when ip forwarding parameter is toggled. 

It adds a new kind of message, RTM_NEWNETCONF.

Following this serie, is a patch against iproute2, to show an example of how to
use it.

Comments are welcome.

Regards,
Nicolas
