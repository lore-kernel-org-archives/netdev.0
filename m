From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/sunhme.c patch
Date: Mon, 29 Oct 2007 15:41:39 -0700 (PDT)
Message-ID: <20071029.154139.19375144.davem@davemloft.net>
References: <Pine.LNX.4.64.0710291606260.26070@fbirervta.pbzchgretzou.qr>
	<20071029.151025.87460351.davem@davemloft.net>
	<Pine.LNX.4.64.0710292311070.32301@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toms@wonderland.us.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbXJ2Wli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:41:38 -0400
In-Reply-To: <Pine.LNX.4.64.0710292311070.32301@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Mon, 29 Oct 2007 23:12:25 +0100 (CET)

> The question was more like: if I put in a QFE (that was acquired together
> with a SUN E250) into x86, would I get duplicate MACs? (Would be strange -
> I would have supposed the OF on the card is independent.)

You are not supposed to.  Each HME instance should get a unique
MAC.

Normally OF would propagate this information around to the independant
device nodes, and we should try to preserve this behavior for non-OF
systems.
