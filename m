From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: warn user when 802.3ad speed is
 unknown
Date: Sat, 10 Jun 2017 16:01:16 -0400 (EDT)
Message-ID: <20170610.160116.642326510430989622.davem@davemloft.net>
References: <20170608164811.GB20216@lunn.ch>
        <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751555AbdFJUBS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:01:18 -0400
In-Reply-To: <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  9 Jun 2017 15:34:43 +0200

> Make it explicit in the log.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I agree with others that we should rate limit this somehow given
the context in which it is invoked.
