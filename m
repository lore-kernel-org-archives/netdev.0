From: David Miller <davem@davemloft.net>
Subject: Re: r8169: Fix card drop incoming VLAN tagged MTU byte large jumbo
 frames
Date: Thu, 29 Oct 2009 22:55:18 -0700 (PDT)
Message-ID: <20091029.225518.96487976.davem@davemloft.net>
References: <4AE60C15.3040206@apollo.lv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: ray@apollo.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49126
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755836AbZJ3Fyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:54:54 -0400
In-Reply-To: <4AE60C15.3040206@apollo.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raimonds Cicans <ray@apollo.lv>
Date: Mon, 26 Oct 2009 22:52:37 +0200

> r8169 card drop incoming VLAN tagged MTU byte large jumbo frames
> 
> It looks to compare current and maximal packet sizes hardware use
> '<' operator, not '<='.
> 
> Bug introduced by patch:
> r8169: fix crash when large packets are received
> 
> Signed-off-by: Raimonds Cicans <ray@apollo.lv>

Applied, thank you.
