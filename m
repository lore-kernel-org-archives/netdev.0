From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: bridge: allow IPv6 when multicast flood is
 disabled
Date: Wed, 01 Mar 2017 20:57:25 -0800 (PST)
Message-ID: <20170301.205725.1502175316481585604.davem@davemloft.net>
References: <1488362128-15217-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdCBGOO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 01:14:14 -0500
In-Reply-To: <1488362128-15217-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Wed, 1 Mar 2017 09:55:28 +0000

> Even with multicast flooding turned off, IPv6 ND should still work so
> that IPv6 connectivity is provided. Allow this by continuing to flood
> multicast traffic originated by us.
> 
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied and queued up for -stable.
