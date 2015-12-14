From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pci tree
Date: Mon, 14 Dec 2015 11:27:21 +1100
Message-ID: <20151214112721.7c60d4b0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Jason S. McMullan" <jason.mcmullan@netronome.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  include/linux/pci_ids.h

between commit:

  a755e169031d ("PCI: Add Netronome vendor and device IDs")

from the pci tree and commit:

  2d1e0254ef83 ("pci_ids: add Netronome Systems vendor")

from the net-next tree.

I fixed it up (the former was just a superset of the latter, so I used
that) and can carry the fix as necessary (no action is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
