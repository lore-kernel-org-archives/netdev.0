From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Fri, 7 Apr 2017 10:22:32 +1000
Message-ID: <20170407102232.34195bed@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/ibm/ibmvnic.c

between commit:

  98998345a579 ("ibmvnic: fix kstrtoul, copy_from_user and copy_to_user misuse")

from the vfs tree and commit:

  e704f0434ea6 ("ibmvnic: Remove debugfs support")

from the net-next tree.

I fixed it up (the latter removed all the code modified by the former,
so I just did that) and can carry the fix as necessary. This is now fixed
as far as linux-next is concerned, but any non trivial conflicts should
be mentioned to your upstream maintainer when your tree is submitted for
merging.  You may also want to consider cooperating with the maintainer
of the conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
