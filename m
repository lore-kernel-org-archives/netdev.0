From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 21:05:00 -0700 (PDT)
Message-ID: <20080831.210500.246648128.davem@davemloft.net>
References: <48BAE26A.4060002@danielinux.net>
	<20080831190916.GA15931@2ka.mipt.ru>
	<48BAEECA.80906@danielinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	angelo.tornese@gmail.com
To: root@danielinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750738AbYIAEFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 00:05:06 -0400
In-Reply-To: <48BAEECA.80906@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Lacamera <root@danielinux.net>
Date: Sun, 31 Aug 2008 21:19:38 +0200

> fast path? I don't think so... the modules allocate the ca_priv once
> per connection, at the beginning of the connection and only if that
> specific module needs that.  Am I missing something?

Creating and destroying a connection is a fast path, that is
what you miss.

The performance of many workloads is directly dependent upon
how fast we can create and tear down a TCP connection.
