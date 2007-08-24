From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/3] move hardware header functions out of netdevice
Date: Fri, 24 Aug 2007 13:43:10 -0700
Message-ID: <20070824204310.388073598@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50532 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752431AbXHXUsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The follow patches series starts the process of moving function
pointers out of network device structure. This saves space and
separates code from data.

The first step is moving the functions dealing with hardware
headers.

Patches are against current net-2.6.24 tree. Basic functional
testing on ethernet part, not on all the other protocols affected.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

