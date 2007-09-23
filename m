From: Steve Wise <swise@opengridcomputing.com>
Subject: pktgen question
Date: Sun, 23 Sep 2007 11:12:12 -0500
Message-ID: <46F6905C.6030309@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:51295 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753859AbXIWQMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 12:12:12 -0400
Received: from [10.10.0.213] (stevo-desktop.ogc.int [10.10.0.213])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 8EFD97C793
	for <netdev@vger.kernel.org>; Sun, 23 Sep 2007 11:12:12 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pktgen module provides a way to "clone" the skb its using for 
transmission, and allows passing N clones of the originally created skb 
to the driver under test.    However, it doesn't really use skb_clone(), 
but rather it just bumps the skb->users count for each "clone" and 
passes the same skb ptr to the driver.

Q: Is that a valid use of skb->users or should pktgen really be cloning 
the skbuff?

Thanks,

Steve.
