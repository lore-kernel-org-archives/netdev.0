From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 00:59:34 -0800 (PST)
Message-ID: <20090305.005934.130220849.davem@davemloft.net>
References: <49AF87D6.5040104@linux.vnet.ibm.com>
	<49AF8CE0.6030301@trash.net>
	<20090305.005646.115456407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, bart@jukie.net,
	greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752212AbZCEI7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 03:59:49 -0500
In-Reply-To: <20090305.005646.115456407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 05 Mar 2009 00:56:46 -0800 (PST)

> Then bond_neigh_setup() has the same bug, doesn't it?

Looking at the bond_main.c changes in:

commit 008298231abbeb91bc7be9e8b078607b816d1a4a
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Thu Nov 20 20:14:53 2008 -0800

    netdev: add more functions to netdevice ops

shows that it always behaved that way.
