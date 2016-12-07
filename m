From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Wed, 7 Dec 2016 15:04:47 +1100
Message-ID: <20161207150447.160b7735@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in:

  drivers/staging/slicoss/slicoss.c

between commit:

  a52ad514fdf3 ("net: deprecate eth_change_mtu, remove usage")

from the net-next tree and commit:

  0af72df267f2 ("staging: slicoss: remove the staging driver")

from the staging tree.

I fixed it up (I just removed the file) and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
