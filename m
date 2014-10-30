From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Add IFF_ALLMULTI support to cpsw (and fix IFF_PROMISC
 support too)
Date: Thu, 30 Oct 2014 16:12:52 -0400 (EDT)
Message-ID: <20141030.161252.246867972287253209.davem@davemloft.net>
References: <20141029190612.GH24110@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029190612.GH24110@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Date: Wed, 29 Oct 2014 15:06:12 -0400

> The cpsw driver did not support the IFF_ALLMULTI flag which makes dynamic
> multicast routing rather hard to handle.  Related to this, when enabling
> IFF_PROMISC in non dual_emac mode, all registered vlans are flushed,
> and only broadcast and unicast are allowed which isn't what you would
> want from IFF_PROMISC.
> 
> A new cpsw_ale_set_allmulti function now scans through the ALE entry
> table and adds or removes the host port from the unregistered multicast
> port mask depending on the state of IFF_ALLMULTI.  In promisc mode,
> it is also called to enable reception of all multicast traffic.
> 
> With this change I am now able to run dynamic multicast routing and also
> use tcpdump and actually see multicast traffic.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

Please fix your Subject line and resubmit this patch.

Subject lines end up as the commit message header text, and
therefore must be of the form:

subsystem: Description.

In this case "cpsw: " is probably an appropriate subsystem
prefix.
