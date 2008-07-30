From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 15:33:40 -0700 (PDT)
Message-ID: <20080730.153340.130551303.davem@davemloft.net>
References: <20080730144812.a71156f7.akpm@linux-foundation.org>
	<20080730.145727.07367670.davem@davemloft.net>
	<20080730151316.a4d76fe9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750991AbYG3Wdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:33:40 -0400
In-Reply-To: <20080730151316.a4d76fe9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 30 Jul 2008 15:13:16 -0700

> If they don't do this then tens of millions of devices will be burdened
> with many kilobytes of code which they will never ever need.

In the current tree, ethtool is even needed with just the core
IPV4 stack, in order to disable LRO when forwarding is enabled.

See dev_disable_lro() and it's callers in net/ipv4/devinet.c
et al.

As Stephen Hemminger mentioned, bridging uses this too.

So essentially, this new config option would need to depend
on CONFIG_INET, and how useful is that?
