From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netlink: let nlmsg and nla functions take
 pointer-to-const args
Date: Tue, 16 Nov 2010 09:52:47 -0800 (PST)
Message-ID: <20101116.095247.48487805.davem@davemloft.net>
References: <alpine.LNX.2.01.1011100106010.10874@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753966Ab0KPRwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 12:52:22 -0500
In-Reply-To: <alpine.LNX.2.01.1011100106010.10874@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Wed, 10 Nov 2010 01:06:36 +0100 (CET)

> parent 2531add5568de01edcabf321d1bbb69a6a6d6c27 (v2.6.36-4468-g2531add)
> commit f87d7f1b74689c96cc2f53b8cabfd309d7ad1bda
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Wed Nov 10 00:10:55 2010 +0100
> 
> netlink: let nlmsg and nla functions take pointer-to-const args
> 
> The changed functions do not modify the NL messages and/or attributes
> at all. They should use const (similar to strchr), so that callers
> which have a const nlmsg/nlattr around can make use of them without
> casting.
> 
> While at it, constify a data array.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied.
