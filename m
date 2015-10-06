From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 6 Oct 2015 11:16:13 +1100
Message-ID: <20151006111613.5f099b3c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/inet_connection_sock.c

between commit:

  2306c704ce28 ("inet: fix race in reqsk_queue_unlink()")

from the net tree and commit:

  079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")

from the net-next tree.

I fixed it up (the latter rewrote the function, so I dropped the net
tree fix) and can carry the fix as necessary (no action is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
