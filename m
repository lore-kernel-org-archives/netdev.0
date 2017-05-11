From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 0/7] bpf: Add alignment tracker to verifier.
Date: Thu, 11 May 2017 12:05:07 -0400 (EDT)
Message-ID: <20170511.120507.1592681423410149174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51524 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933097AbdEKQFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First we add the alignment tracking logic to the verifier.

Next, we work on building up infrastructure to facilitate regression
testing of this facility.

Next, we add the "test_align" test case.

Finally, we let the map value pointer checks use the new
infrastructure and adjust test_verifier to match.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

v1 -->v2:
	Adjustments based upon Daniel's feedback
	Add map value and test_verifier changes
