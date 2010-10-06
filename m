From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 0/4] Revamp PPP fragmentation handling
Date: Tue, 05 Oct 2010 19:52:14 -0700 (PDT)
Message-ID: <20101005.195214.226791121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756478Ab0JFCvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 22:51:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1BE0B24C087
	for <netdev@vger.kernel.org>; Tue,  5 Oct 2010 19:52:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If someone uses PPP fragmentation actively and can test this
code out, I'd really appreciate it.

The main goal is to make the fragmentation code not reference
the internals of our SKB queue and list implementation.

Along the way the printk's were also cleaned up, and also
instead of copying fragments into newly allocated linear
skbs, we use frag lists.
