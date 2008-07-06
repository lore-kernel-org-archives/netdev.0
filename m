From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Sat, 05 Jul 2008 21:21:38 -0700 (PDT)
Message-ID: <20080705.212138.06508305.davem@davemloft.net>
References: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbYGFEVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 00:21:38 -0400
In-Reply-To: <486E1074.7040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 04 Jul 2008 15:58:44 +0400

> This is the first small set of MIB statistics netnsization. The easiest
> case is UDP stats, so I started with this one. If this set is accepted,
> I will go on step-by-step with adding struct net to all the other stats' 
> accounting macros, then SNMP_XXX ones and finish with a set than will put 
> the stats on the struct net and fix appropriate proc files.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: Denis V. Lunev <den@openvz.org>

Applied, thanks Pavel.

Are we going to provide some way for an administrator to fetch
stats from the perspective of all namespaces?  I know the idea
is seperation with this stuff, but admins are going to want
something like that.

