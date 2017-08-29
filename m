From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bcmgenet: Use correct I/O accessors
Date: Tue, 29 Aug 2017 16:09:24 -0700 (PDT)
Message-ID: <20170829.160924.1500444618699306222.davem@davemloft.net>
References: <1504034731-31613-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdH2XJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:09:25 -0400
In-Reply-To: <1504034731-31613-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Aug 2017 12:25:31 -0700

> The GENET driver currently uses __raw_{read,write}l which means
> native I/O endian. This works correctly for an ARM LE kernel (default)
> but fails miserably on an ARM BE (BE8) kernel where registers are kept
> little endian, so replace uses with {read,write}l_relaxed here which is
> what we want because this is all performance sensitive code.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
