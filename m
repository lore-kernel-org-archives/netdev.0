From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 20 Jun 2016 11:20:46 +1000
Message-ID: <20160620112046.43715de9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:57679 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbcFTBWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2016 21:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/qlogic/qed/qed_hsi.h

between commit:

  b639f197210d ("qed: Add missing port-mode")

from the net tree and commit:

  351a4dedb34c ("qed: Utilize FW 8.10.3.0")

from the net-next tree.

I fixed it up (the net-next tree version is a superset of the net tree
version) and can carry the fix as necessary. This is now fixed as far as
linux-next is concerned, but any non trivial conflicts should be mentioned
to your upstream maintainer when your tree is submitted for merging.
You may also want to consider cooperating with the maintainer of the
conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
