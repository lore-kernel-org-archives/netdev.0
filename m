From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/14] [TIPC] Added duplicate node address detection
 capability
Date: Mon, 16 Oct 2006 21:45:34 -0700 (PDT)
Message-ID: <20061016.214534.102577213.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394752476-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38050
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423044AbWJQEpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:45:35 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394752476-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:45 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> TIPC now rejects and logs link setup requests from node <Z.C.N> if the
> receiving node already has a functional link to that node on the associated
> interface, or if the requestor is using the same <Z.C.N> as the receiver.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, but more whitespace crap I had to fix up:

davem@sunset:~/src/GIT/net-2.6$ pcheck diff
+ git apply --check --whitespace=error-all diff
Adds trailing whitespace.
diff:19:		tipc_printf(pb, "%s(%s)", m_ptr->name, 
Adds trailing whitespace.
diff:46:static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr, 
Adds trailing whitespace.
diff:84:				spin_unlock_bh(&n_ptr->lock);                
fatal: 3 lines add trailing whitespaces.
