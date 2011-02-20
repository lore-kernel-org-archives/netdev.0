From: David Miller <davem@davemloft.net>
Subject: libmnl limitation...
Date: Sun, 20 Feb 2011 13:41:28 -0800 (PST)
Message-ID: <20110220.134128.115926805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754363Ab1BTVkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:40:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unfortunately, libmnl only allows setting socket options
that are of SOL_NETLINK.

This precludes setting socket options such as SO_ATTACH_FILTER
which need to be of level SOL_SOCKET.

It seems to be a mistake to have hard-coded the socket level
instead of simply letting the user specify it :-/
