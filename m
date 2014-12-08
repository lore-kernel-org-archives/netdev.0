From: kxie@chelsio.com
Subject: [PATCH net v2 0/5] cxgb4/cxgbi: misc. fixes for cxgb4i
Date: Mon, 08 Dec 2014 01:58:05 -0800
Message-ID: <201412080958.sB89w5JZ005481@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6261 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbaLHJ7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 04:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v2 0/5] cxgb4/cxgbi: misc. fixes for cxgb4i

This patch set fixes cxgb4i's tx credit calculation and adds handling of additional rx messages and types of negative advice. It also removes the duplicate code in cxgb4i to set the outgoing queues of a packet. 

Karen Xie (5):
cxgb4i: check if wr header is required when calculating tx credit
cxgb4/cxgb4i: set max. outgoing pdu length in the f/w
cxgb4i: handle non pdu-aligned rx data and additional types of negative advice 
cxgb4i: use cxgb4's set_wr_txq() for setting outgoing queues
libcxgbi: fix the debug print accessing skb after it is freed

Sending to net as the fixes are mostly in the network area and it touches cxgb4's header file (t4fw_api.h).

v2 corrects the "CHECK"s flagged by checkpatch.pl --strict.
