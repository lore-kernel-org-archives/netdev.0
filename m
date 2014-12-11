From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v9 0/7] cxgb4/cxgbi: misc. fixes for cxgb4i
Date: Thu, 11 Dec 2014 07:25:37 -0800
Message-ID: <201412111525.sBBFPbfn012920@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set fixes cxgb4i's tx credit calculation and adds handling of
additional rx message and negative advice types. It also removes the duplicate
code in cxgb4i to set the outgoing queues of a packet. 

Karen Xie (7):
cxgb4i: fix tx immediate data credit check
cxgb4i: fix credit check for tx_data_wr
cxgb4/cxgb4i: set max. outgoing pdu length in the f/w
cxgb4i: add more types of negative advice 
cxgb4i: handle non pdu-aligned rx data
cxgb4i: use cxgb4's set_wr_txq() for setting outgoing queues
libcxgbi: fix the debug print accessing skb after it is freed

Sending to net as the fixes are mostly in the network area and it touches
cxgb4's header file (t4fw_api.h).

v2 corrects the "CHECK"s flagged by checkpatch.pl --strict.

v3 splits the 3rd patch from v2 to two separate patches. Adds detailed commit
messages and makes subject more concise. Patch 3/6 also changes the return
value of is_neg_adv() from int to bool.

v4 -- please ignore.

v5 splits the 1st patch from v3 to two separate patches and reduces code
duplication in make_tx_data_wr().

v6 removed the code style cleanup in the 2nd patch. The style update will be
addressed in a separate patch.

v7 updates the 7th patch with more detailed commit message.

v8 removes the duplicate subject lines from the message bodies.

v9 reformatted the commit messages to be max. 80 characters per line.
