From: Karen Xie <kxie@chelsio.com>
Subject: RE: [PATCH net v4 0/7] cxgb4/cxgbi: misc. fixes for cxgb4i
Date: Wed, 10 Dec 2014 01:46:32 +0000
Message-ID: <1442C3287A121140B690F7F20F94463D82E186@nice.asicdesigners.com>
References: <201412100132.sBA1WpsR024833@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	Anish Bhatt <anish@chelsio.com>,
	"hch@infradead.org" <hch@infradead.org>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Karen Xie <kxie@chelsio.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201412100132.sBA1WpsR024833@localhost6.localdomain6>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please ignore v4. Sent v5 already.

-----Original Message-----
From: Karen Xie [mailto:kxie@chelsio.com] 
Sent: Tuesday, December 09, 2014 5:33 PM
To: linux-scsi@vger.kernel.org; netdev@vger.kernel.org
Cc: Karen Xie; Hariprasad S; Anish Bhatt; hch@infradead.org; James.Bottomley@HansenPartnership.com; michaelc@cs.wisc.edu; davem@davemloft.net
Subject: [PATCH net v4 0/7] cxgb4/cxgbi: misc. fixes for cxgb4i

[PATCH net v4 0/7] cxgb4/cxgbi: misc. fixes for cxgb4i

This patch set fixes cxgb4i's tx credit calculation and adds handling of additional rx message and negative advice types. It also removes the duplicate code in cxgb4i to set the outgoing queues of a packet. 

Karen Xie (7):
cxgb4i: fix tx immediate data credit check
cxgb4i: fix credit check for tx_data_wr
cxgb4/cxgb4i: set max. outgoing pdu length in the f/w
cxgb4i: add more types of negative advice 
cxgb4i: handle non pdu-aligned rx data
cxgb4i: use cxgb4's set_wr_txq() for setting outgoing queues
libcxgbi: fix the debug print accessing skb after it is freed

Sending to net as the fixes are mostly in the network area and it touches cxgb4's header file (t4fw_api.h).

v2 corrects the "CHECK"s flagged by checkpatch.pl --strict.

v3 splits the 3rd patch from v2 to two seperate patches. Adds detailed commit messages and makes subject more concise. Patch 3/6 also changes the return value of is_neg_adv() from int to bool.

v4 splits the 1st patch from v3 to two seperate patches and reduces code duplication in make_tx_data_wr().
