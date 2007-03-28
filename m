From: David Miller <davem@davemloft.net>
Subject: reverting handle_bridge() change from net-2.6.22
Date: Tue, 27 Mar 2007 19:38:09 -0700 (PDT)
Message-ID: <20070327.193809.74746967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933569AbXC1CiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 22:38:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It doesn't build with bridging disabled, and I can't see
exactly how to work out the 'ret' assignment in the way
the new code works so I'm reverting.

Please resubmit a version that builds and works properly
with bridging enabled and disabled, thanks :-)
