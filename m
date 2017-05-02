From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Fix some bpf program testing framework bugs
Date: Tue, 02 May 2017 11:36:16 -0400 (EDT)
Message-ID: <20170502.113616.583190751944798030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBPgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series fixes two issue:

1) Accidental user pointer dereference in bpf_test_finish()

2) The packet data given to the test programs is not aligned correctly

The first issue is fixed simply because we have a kernel side copy
of the datastructure in question already.  And the second bug is
a simple matter of applying NET_IP_ALIGN where needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
