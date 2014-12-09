From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v3 0/6] cxgb4/cxgbi: misc. fixes for cxgb4i
Date: Tue, 09 Dec 2014 09:32:14 -0800
Message-ID: <201412091732.sB9HWESJ008990@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6418 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaLIRdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v3 0/6] cxgb4/cxgbi: misc. fixes for cxgb4i

This patch set fixes cxgb4i's tx credit calculation and adds handling of additional rx message and negative advice types. It also removes the duplicate code in cxgb4i to set the outgoing queues of a packet. 

Karen Xie (6):
cxgb4i: check if wr header is required when calculating tx credit
cxgb4/cxgb4i: set max. outgoing pdu length in the f/w
cxgb4i: add more types of negative advice 
cxgb4i: handle non pdu-aligned rx data
cxgb4i: use cxgb4's set_wr_txq() for setting outgoing queues
libcxgbi: fix the debug print accessing skb after it is freed

Sending to net as the fixes are mostly in the network area and it touches cxgb4's header file (t4fw_api.h).

v2 corrects the "CHECK"s flagged by checkpatch.pl --strict.

v3 splits the 3rd patch from v2 to two seperate patches. Adds detailed commit messages and makes subject more concise. Patch 3/6 also changes the return value of is_neg_adv() from int to bool as recommended by Sergei.
