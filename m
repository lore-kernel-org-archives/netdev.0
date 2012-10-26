From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 0/5] Allow to monitor protocol configuration
Date: Fri, 26 Oct 2012 10:28:48 +0200
Message-ID: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38304 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab2JZITr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:19:47 -0400
In-Reply-To: <20121026.021830.1470799532580844849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie aims to advertising via netlink any change in the network
configuration of a protocol (network or transport). For example the announcement
when ip forwarding parameter is toggled. 

It adds a new kind of messages, RTM_NEWNETCONF/RTM_GETNETCONF.

The patch which adds the support of netconf messages in iproute2 will be sent
when the feature will be included.  If someone is interested to get it before,
just tell me!

v3: remove inline attribute in non header files

v2: rename functions to be consistent
    specify type of the attribute to notify when calling
    inet[6]_netconf_notify_devconf(), goal is to notify only thinks that
    changed.
    add RTM_GETNETCONF support

Comments are welcome.

Regards,
Nicolas
