From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 17 Jul 2015 10:49:08 +1000
Message-ID: <20150717104908.1f16d4c0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Satish Ashok <sashok@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/bridge/br_mdb.c

between commit:

  5ebc784625ea ("bridge: mdb: fix double add notification")

from the net tree and commit:

  09cf0211f970 ("bridge: mdb: fill state in br_mdb_notify")

from the net-next tree.

I fixed it up (I removed the br_mdb_notify call as per the former patch)
and can carry the fix as necessary (no action is required).



-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
