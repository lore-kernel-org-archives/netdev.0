From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethtool: Replace memset with compiler directive
Date: Thu, 08 Jun 2017 10:23:42 -0400 (EDT)
Message-ID: <20170608.102342.969656909338882182.davem@davemloft.net>
References: <20170608133221.608-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, allan.nielsen@microsemi.com,
        Raju.Lakkaraju@microsemi.com, jakub.kicinski@netronome.com,
        steffen.klassert@secunet.com, ast@fb.com, sgruszka@redhat.com,
        mlichvar@redhat.com, netdev@vger.kernel.org
To: yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdFHOXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:23:44 -0400
In-Reply-To: <20170608133221.608-1-yuval.shaia@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Thu,  8 Jun 2017 16:32:21 +0300

> Take advantage of compiler variable zero-ing and remove calls to memset.
> 
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>

That construct looks so ugly, also the memset()'s in some cases are
constrained to the basic blockwhere the variable is used, avoiding an
initialization unnecessarily.

I'm not applying this, sorry.
