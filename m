From: kxie@chelsio.com
Subject: [PATCH v2 0/3] cxgbi iscsi driver
Date: Fri, 13 Aug 2010 08:19:54 -0700
Message-ID: <201008131519.o7DFJsaH002618@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rranjan@chelsio.com, kxie@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31132 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761685Ab0HMPUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 11:20:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH v2 0/3] cxgbi iscsi driver

From: Karen Xie <kxie@chelsio.com>

Re-submission, missed netdev list last time.

This patchset includes:

1. added libcxgbi as the common library for both cxgb4i and cxgb3i driver
2. added cxgb4i iscsi initiator v5.
3. changed cxgb3i to use libcxgbi.

The version 2 includes the following changes:
- Made dbg_level static to avoid compiling errors when both cxgb3i and cxgb4i
  are built into the kernel.
- Deleted cxgbi_fill_iscsi_transport() and cxgbi_fill_scsi_host_template().
  The iscsi_transport and scsi_host_template are initialized in the drivers
  instead of being filled in by the library at runtime..
- Only register with iscsi class transport once per driver type. 

Thanks.
Karen
