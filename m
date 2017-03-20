From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 20 Mar 2017 11:02:00 +1100
Message-ID: <20170320110200.239425f5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        stephen hemminger <stephen@networkplumber.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/hyperv/netvsc.c

between commit:

  e14b4db7a567 ("netvsc: fix race during initialization")

from the net tree and commits:

  0d6dd35784e7 ("netvsc: need napi scheduled during removal")
  6de38af611ca ("netvsc: avoid race with callback")

from the net-next tree.

I fixed it up (I just used the net-next version) and can carry the fix
as necessary. This is now fixed as far as linux-next is concerned, but
any non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

P.S. the Signed-off-bys do not match the Author email addresses.

-- 
Cheers,
Stephen Rothwell
