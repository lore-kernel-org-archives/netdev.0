From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: use correct barrier between cacheable and
 non-cacheable memory
Date: Thu, 04 Mar 2010 00:40:48 -0800 (PST)
Message-ID: <20100304.004048.09651248.davem@davemloft.net>
References: <1267669990.23829.8.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, paulus@samba.org,
	catalin.marinas@arm.com
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946Ab0CDIk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:40:29 -0500
In-Reply-To: <1267669990.23829.8.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Wed, 03 Mar 2010 21:33:10 -0500

> r8169 needs certain writes to be visible to other CPUs or the NIC before
> touching the hardware, but was using smp_wmb() which is only required to
> order cacheable memory access. Switch to wmb() which is required to
> order both cacheable and non-cacheable memory.
> 
> Noticed by Catalin Marinas and Paul Mackerras.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

Applied.
