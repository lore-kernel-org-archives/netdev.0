From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] be2net: use shift instead of expensive divide
Date: Mon, 28 Aug 2017 21:25:32 -0700 (PDT)
Message-ID: <20170828.212532.681511354269866877.davem@davemloft.net>
References: <1503976719-3063-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdH2EZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 00:25:33 -0400
In-Reply-To: <1503976719-3063-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 29 Aug 2017 11:18:39 +0800

> Replace shift instead of expensive divide.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

The divide is more easier to understand, and it costs the same
as a shift if the types are unsigned.

I'm not applying silly changes like this which actually make
the code worse off, sorry.
