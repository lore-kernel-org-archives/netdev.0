From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 21 Apr 2016 19:54:23 -0400
Message-ID: <87mvomr00g.fsf@ketchup.mtl.sfl>
References: <20160418113038.00d78799@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160418113038.00d78799@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/dsa/mv88e6xxx.c
>
> between commit:
>
>   207afda1b503 ("net: dsa: mv88e6xxx: share the same default FDB")
>
> from the net tree and commit:
>
>   009a2b9843bf ("net: dsa: mv88e6xxx: add number of ports to info")
>
> from the net-next tree.
>
> I fixed it up (the former removed some of the code updated by the latter)
> and can carry the fix as necessary. This is now fixed as far as linux-next
> is concerned, but any non trivial conflicts should be mentioned to your
> upstream maintainer when your tree is submitted for merging.  You may
> also want to consider cooperating with the maintainer of the conflicting
> tree to minimise any particularly complex conflicts.

I have another series to send to net-next which will also conflict with this
fix from net. As it is also required in net-next, can the fix be merged
in net-next as well?

This fix is the 3 commits:

  65fa40276ac1 ("net: dsa: mv88e6xxx: unlock DSA and CPU ports")
  996ecb824667 ("net: dsa: mv88e6xxx: enable SA learning on DSA ports")
  207afda1b503 ("net: dsa: mv88e6xxx: share the same default FDB")

For the merge commit:

  cf6b5fb2514d ("Merge branch 'dsa-mv88e6xxx-fix-cross-chip-bridging'")

Regards,
Vivien
