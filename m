From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] problem with BPF in PF_PACKET sockets, introduced in
 linux-2.6.19
Date: Thu, 25 Jan 2007 15:53:38 -0800 (PST)
Message-ID: <20070125.155338.97294103.davem@davemloft.net>
References: <200701041747.46358.raivis@mt.lv>
	<20070124.152133.61337361.davem@davemloft.net>
	<20070125132220.GA15410@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raivis@mt.lv, netdev@vger.kernel.org, waltje@uWalt.NL.Mugnet.ORG,
	gw4pts@gw4pts.ampr.org, dim@openvz.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030647AbXAYXxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 18:53:39 -0500
In-Reply-To: <20070125132220.GA15410@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Thu, 25 Jan 2007 16:22:20 +0300

> Actually, it can. Return value was used only as sign of error,
> so that the mistake was to return original unsigned result casted to int.
> 
> Alternative fix is enclosed. To be honest, it is not better than
> yours: duplication of couple lines of code against passing return
> value by pointer.

Yes, this version of a fix would work as well.
