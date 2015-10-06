From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 6 Oct 2015 11:11:48 +1100
Message-ID: <20151006111148.27b5225a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David B. Robins" <linux@davidrobins.net>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:44780 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbbJFALw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 20:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/usb/asix_common.c

between commit:

  f6194bcf03e4 ("net: usb: asix: Fix crash on skb alloc failure")

from the net tree and commit:

  6a570814cd43 ("asix: Continue processing URB if no RX netdev buffer")
(among others)

from the net-next tree.

I fixed it up (I dropped the net tree fixup (assuming that it was fixed
in some other manner in the net-next tree)) and can carry the fix as
necessary (no action is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
