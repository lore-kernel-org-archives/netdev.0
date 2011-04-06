From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix panic in ip6_pol_route
Date: Wed, 06 Apr 2011 01:21:33 -0700 (PDT)
Message-ID: <20110406.012133.71132393.davem@davemloft.net>
References: <20110406064504.30691.36599.sendpatchset@krkumar2.in.ibm.com>
	<20110406.004043.193732725.davem@davemloft.net>
	<OFCD49CDC4.C2B9408D-ON6525786A.002C2B92-6525786A.002CBDC6@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51269
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754635Ab1DFIWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 04:22:10 -0400
In-Reply-To: <OFCD49CDC4.C2B9408D-ON6525786A.002C2B92-6525786A.002CBDC6@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 6 Apr 2011 13:40:57 +0530

> Is it better to disallow configuring vlan on lo?

Yes, but the real stinker to me is that the IFF_LOOPBACK flag
propagates to the VLAN device, that really seems even more
wrong to me.
