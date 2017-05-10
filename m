From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] bpf: Add alignment tracker to verifier.
Date: Wed, 10 May 2017 15:09:34 -0400 (EDT)
Message-ID: <20170510.150934.443127288314672547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753224AbdEJTJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 15:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the whole series, more details in the individual commit
messages.

First we add the alignment tracking logic to the verifier.

Next, we work on building up infrastructure to facilitate regression
testing of this facility.

Finally, we add the "test_align" test case.

Signed-off-by: David S. Miller <davem@davemloft.net>
