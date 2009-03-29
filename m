From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: Two OF network driver bug fixes.
Date: Sun, 29 Mar 2009 03:18:39 -0700 (PDT)
Message-ID: <20090329.031839.182571231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753987AbZC2KSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:18:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3C4A7C8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:18:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both ucc_geth and gianfar have a bug wherein they release
an OF device node object before they are done using it.
