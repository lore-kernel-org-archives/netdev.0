From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: add NLM_F_APPEND in notifications
 when applicable
Date: Wed, 01 Feb 2017 12:14:08 -0500 (EST)
Message-ID: <20170201.121408.899537853398999897.davem@davemloft.net>
References: <1485910297-14092-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752861AbdBAROJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:14:09 -0500
In-Reply-To: <1485910297-14092-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 31 Jan 2017 16:51:37 -0800

> IPv6 does not set the NLM_F_APPEND flag in notifications to signal that
> a NEWROUTE is an append versus a new route or a replaced one. Add the
> flag if the request has it.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> sending this one outside of the multipath patch set since it has
> nothing to do with multipath.

Looks good Dave, applied, thank you.
