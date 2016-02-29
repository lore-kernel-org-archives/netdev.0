From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the target-merge tree with the net-next
 tree
Date: Mon, 29 Feb 2016 17:39:11 +1100
Message-ID: <20160229173911.4fabe3f8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Varun Prakash <varun@chelsio.com>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicholas,

Today's linux-next merge of the target-merge tree got a conflict in:

  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h

between commit:

  ba9cee6aa67d ("cxgb4/iw_cxgb4: TOS support")

from the net-next tree and commit:

  c973e2a3ff1b ("cxgb4: add definitions for iSCSI target ULD")

from the target-merge tree.

I fixed it up (the latter was a superset of the former) and can carry
the fix as necessary (no action is required).

-- 
Cheers,
Stephen Rothwell
