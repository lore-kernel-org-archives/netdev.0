From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Bring back transceiver type for PHYLIB
Date: Thu, 21 Sep 2017 15:20:57 -0700 (PDT)
Message-ID: <20170921.152057.344956479875665375.davem@davemloft.net>
References: <20170920225214.21974-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, decot@googlers.com,
        tremyfr@gmail.com, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:20:58 -0400
In-Reply-To: <20170920225214.21974-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 20 Sep 2017 15:52:12 -0700

> With the introduction of the xLINKSETTINGS ethtool APIs, the transceiver type
> was deprecated, but in that process we lost some useful information that PHYLIB
> was consistently reporting about internal vs. external PHYs.
> 
> This brings back transceiver as a read-only field that is only consumed in the
> legacy path where ETHTOOL_GET is called but the underlying drivers implement the
> new style klink_settings API.

Series applied, thanks Florian.
