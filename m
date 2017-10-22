From: David Miller <davem@davemloft.net>
Subject: [MERGE README] net --> net-next
Date: Sun, 22 Oct 2017 13:57:17 +0100 (WEST)
Message-ID: <20171022.135717.971703426919688431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@kernel.org, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdJVM5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 08:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There were quite a few BPF conflicts during the merge I just did of
'net' into 'net-next'.

In particular, all of the packet pointer branch tests in the verifier
had to be resolved wrt. three different sets of changes.

The off-by-one stuff.  The allowance of the 'data_end > ptr + x' form
of packet pointer checks.  And finally, the metadata stuff.

I would really appreciate an audit and double check of my merge work
by the interested parties.

Thank you.
