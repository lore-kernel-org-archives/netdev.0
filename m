From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 9 May 2016 10:43:07 +1000
Message-ID: <20160509104307.180cee9b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jarno Rajahalme <jarno@ovn.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  include/linux/netdevice.h

between commit:

  229740c63169 ("udp_offload: Set encapsulation before inner completes.")

from the net tree and commit:

  46aa2f30aa7f ("udp: Remove udp_offloads")

from the net-next tree.

I fixed it up (the latter removed the struct that was commented in the
former) and can carry the fix as necessary. This is now fixed as far as
linux-next is concerned, but any non trivial conflicts should be mentioned
to your upstream maintainer when your tree is submitted for merging.
You may also want to consider cooperating with the maintainer of the
conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
