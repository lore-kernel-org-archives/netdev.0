From: David Miller <davem@davemloft.net>
Subject: Re: drivers: net: cpsw: Support ALLMULTI and fix IFF_PROMISC in
 switch mode
Date: Fri, 31 Oct 2014 16:17:17 -0400 (EDT)
Message-ID: <20141031.161717.851599743414417317.davem@davemloft.net>
References: <20141031173852.GK24110@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141031173852.GK24110@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Date: Fri, 31 Oct 2014 13:38:52 -0400

> The cpsw driver did not support the IFF_ALLMULTI flag which makes dynamic
> multicast routing not work.  Related to this, when enabling IFF_PROMISC
> in switch mode, all registered multicast addresses are flushed, resulting
> in only broadcast and unicast traffic being received.
> 
> A new cpsw_ale_set_allmulti function now scans through the ALE entry
> table and adds/removes the host port from the unregistered multicast
> port mask of each vlan entry depending on the state of IFF_ALLMULTI.
> In promiscious mode, cpsw_ale_set_allmulti is used to force reception
> of all multicast traffic in addition to the unicast and broadcast traffic.
> 
> With this change dynamic multicast and promiscious mode both work in
> switch mode.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

Applied.
