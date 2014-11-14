From: David Miller <davem@davemloft.net>
Subject: Re: net-next panic in ovs call to arch_fast_hash2 since e5a2c899
Date: Thu, 13 Nov 2014 21:45:49 -0500 (EST)
Message-ID: <20141113.214549.1520205472319716774.davem@davemloft.net>
References: <12086.1415931332@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, discuss@openvswitch.org,
	pshelar@nicira.com, ogerlitz@mellanox.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933518AbaKNCpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 21:45:54 -0500
In-Reply-To: <12086.1415931332@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Thu, 13 Nov 2014 18:15:32 -0800

> 	The "have feature" function, __intel_crc4_2_hash2, does not
> clobber %r8, and so the call does not panic on a system with
> X86_FEATURE_XMM4_2, although I'm not sure if that's a deliberate
> compiler action or just happenstance because __intel_crc4_2_hash2 uses
> fewer registers than __jhash2.

Perhaps alternative calls can only be used with assembler routines
that use specific calling conventions, and they therefore generally
don't work with C functions?
