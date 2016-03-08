From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 8 Mar 2016 11:37:19 +1100
Message-ID: <20160308113719.68a56294@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/tipc/subscr.c

between commit:

  4de13d7ed6ff ("tipc: fix nullptr crash during subscription cancel")

from the net tree and commit:

  7c13c6224123 ("tipc: introduce tipc_subscrb_subscribe() routine")
(and following ones)

from the net-next tree.

I fixed it up (I used the net-next tree version as it is not obvious tha
the net tree patch is still needed) and can carry the fix as necessary
(no action is required).

-- 
Cheers,
Stephen Rothwell
