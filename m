From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] vxlan: implement Generic Protocol
 Extension (GPE)
Date: Wed, 06 Apr 2016 16:50:50 -0400 (EDT)
Message-ID: <20160406.165050.2038144809203696976.davem@davemloft.net>
References: <cover.1459860270.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jesse@kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbcDFUuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:50:52 -0400
In-Reply-To: <cover.1459860270.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  5 Apr 2016 14:47:09 +0200

> v3: just rebased on top of the current net-next, no changes
> 
> This patchset implements VXLAN-GPE. It follows the same model as the tun/tap
> driver: depending on the chosen mode, the vxlan interface is created either
> as ARPHRD_ETHER (non-GPE) or ARPHRD_NONE (GPE).
> 
> Note that the internal fdb control plane cannot be used together with
> VXLAN-GPE and attempt to configure it will be rejected by the driver. In
> fact, COLLECT_METADATA is required to be set for now. This can be relaxed in
> the future by adding support for static PtP configuration; it will be
> backward compatible and won't affect existing users.
> 
> The previous version of the patchset supported two GPE modes, L2 and L3. The
> L2 mode (now called "ether mode" in the code) was removed from this version.
> It can be easily added later if there's demand. The L3 mode is now called
> "raw mode" and supports also encapsulated Ethernet headers (via ETH_P_TEB).
> 
> The only limitation of not having "ether mode" for GPE is for ip route based
> encapsulation: with such setup, only IP packets can be encapsulated. Meaning
> no Ethernet encapsulation. It seems there's not much use for this, though.
> If it turns out to be useful, we'll add it.

Series applied, thanks Jiri.
