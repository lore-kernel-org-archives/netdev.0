From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dwc-xlgmac: add the initial ethtool
 support
Date: Tue, 11 Apr 2017 10:47:49 -0400 (EDT)
Message-ID: <20170411.104749.1916353709565387637.davem@davemloft.net>
References: <f1495b53a7ddd2c4bbccdd4b629f57035139c7b6.1491898365.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jie.Deng1@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752914AbdDKOrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:47:51 -0400
In-Reply-To: <f1495b53a7ddd2c4bbccdd4b629f57035139c7b6.1491898365.git.jiedeng@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Deng <Jie.Deng1@synopsys.com>
Date: Tue, 11 Apr 2017 16:14:04 +0800

> It is necessary to provide ethtool support for displaying and
> modifying parameters of dwc-xlgmac.
> 
> Signed-off-by: Jie Deng <jiedeng@synopsys.com>

I don't see why you cannot allow the statistics to be obtained when
the device is not running.  Similarly for other ethtool calls that
just fetch information stored in the software state of the driver.

I think your ->begin() method is way too restrictive.
