From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources per
	NUMA node
Date: Tue, 19 Jan 2010 20:34:00 +0100
Message-ID: <20100119193400.GB24652@basil.fritz.box>
References: <20100107044741.28605.31414.stgit@localhost.localdomain> <87y6k1dk5t.fsf@basil.nowhere.org> <F86E8680A7D9D74A99DC6345E35A6929502312B0@orsmsx503.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52198 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab0ASTeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 14:34:09 -0500
Content-Disposition: inline
In-Reply-To: <F86E8680A7D9D74A99DC6345E35A6929502312B0@orsmsx503.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >The problem of doing this is that the node might be full or have
> >no memory and k*alloc_node will fail then.
> >
> >So you would need a fallback to be reliable (we probably should have a
> >generic utility function for this somewhere, but we don't currently)
> 
> So you'd rather see us call kzalloc() if kzalloc_node() fails, instead of immediately failing out to err_out?

Yes.

After all it's only an optimization to place memory, it's not
a functional requirement.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
