From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Tue, 30 Sep 2008 07:10:23 -0700 (PDT)
Message-ID: <20080930.071023.07946874.davem@davemloft.net>
References: <48E141F3.9000903@cosmosbay.com>
	<20080929223801.GA3157@hmsreliant.think-freely.org>
	<48E1C104.2080801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754132AbYI3OKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:10:35 -0400
In-Reply-To: <48E1C104.2080801@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 30 Sep 2008 08:02:44 +0200

> When a machine is targeted by a DDOS attack, about all slots of the
> hash table are fully loaded (ie chain length >= elasticity). We dont
> need to invalidate the cache, but find an equilibrium, with small
> adjustements.

Sure, but it is possible to determine that some hash chains
are unevenly growing out of control compared to others,
and that is the algorithm that Neil is trying to discover.
