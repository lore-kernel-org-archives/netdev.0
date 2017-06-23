From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnxt_en: Error handling and netpoll fixes.
Date: Fri, 23 Jun 2017 14:53:20 -0400 (EDT)
Message-ID: <20170623.145320.426640465802976951.davem@davemloft.net>
References: <1498240861-17730-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSxW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:53:22 -0400
In-Reply-To: <1498240861-17730-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 23 Jun 2017 14:00:59 -0400

> Add missing error handling and fix netpoll handling.  The current code
> handles RX and TX events in netpoll mode and is causing lots of warnings
> and errors in the RX code path in netpoll mode.  The fix is to only handle
> TX events in netpoll mode.

Series applied, thanks.
