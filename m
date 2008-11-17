From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Mon, 17 Nov 2008 15:42:07 -0800
Message-ID: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55032 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371AbYKQX7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sequence of patches breaks the network device adminstration 
function table away from the network device data structure. It is
a transitional API change (both keep working), and this set of patches
hits a range of commonly used drivers. This should be enough to make sure
both old and new interfaces get used and tested.

-- 

