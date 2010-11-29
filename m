From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] IPv6 inetpeer support
Date: Mon, 29 Nov 2010 13:43:57 -0800 (PST)
Message-ID: <20101129.134357.102563313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51847
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442Ab0K2Vnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 16:43:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 39E4324C088
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 13:43:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is the beginning of some refactoring I've been working on.

It's a respin of my older inet-peer ipv6 support patch plus the
beginnings of what's necessary to support TCP time-wait recycling
in ipv6 too.

I also intend to investigate more deeply putting metrics into
the inet-peer cache, but nothing about that is in this series
as that is still a not so clear-and-dry issue.

Supporting the same set of TCP features in both ipv4 and ipv6
is, on the other hand, less controversial so I think we should
do the ipv6 inet-peer thing no matter what.
