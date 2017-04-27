From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bridge: add per-port broadcast flood flag
Date: Thu, 27 Apr 2017 16:34:44 -0400 (EDT)
Message-ID: <20170427.163444.2182045175923211459.davem@davemloft.net>
References: <1493214489-9921-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968401AbdD0Ueq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:34:46 -0400
In-Reply-To: <1493214489-9921-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Wed, 26 Apr 2017 14:48:09 +0100

> Support for l2 multicast flood control was added in commit b6cb5ac8331b
> ("net: bridge: add per-port multicast flood flag"). It allows broadcast
> as it was introduced specifically for unknown multicast flood control.
> But as broadcast is a special case of multicast, this may also need to
> be disabled. For this purpose, introduce a flag to disable the flooding
> of received l2 broadcasts. This approach is backwards compatible and
> provides flexibility in filtering for the desired packet types.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied, thanks for following up on this.
