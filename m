From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] thunderbolt: Drop sequence number check from
 tb_xdomain_match()
Date: Fri, 27 Oct 2017 12:01:41 +0900 (KST)
Message-ID: <20171027.120141.2030619458420639672.davem@davemloft.net>
References: <20171025092734.51299-1-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, michael.jamet@intel.com,
        yehezkel.bernat@intel.com, dan.carpenter@oracle.com,
        amir.jer.levy@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932443AbdJ0DBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 23:01:45 -0400
In-Reply-To: <20171025092734.51299-1-mika.westerberg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Wed, 25 Oct 2017 12:27:34 +0300

> Commit 9a03c3d398c1 ("thunderbolt: Fix a couple right shifting to zero
> bugs") revealed an issue that was previously hidden because we never
> actually compared received XDomain message sequence numbers properly.
> The idea with these sequence numbers is that the responding host uses
> the same sequence number that was in the request packet which we can
> then check at the requesting host.
> 
> However, testing against macOS it looks like it does not follow this but
> instead uses some other logic. Windows driver on the other hand handles
> it the same way than Linux.
> 
> In order to be able to talk to macOS again, fix this so that we drop the
> whole sequence number check. This effectively works exactly the same
> than it worked before the aforementioned commit. This also follows the
> logic the original P2P networking code used.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> ---
> This applies on top of net-next.git/master.

Applied, thank you.
