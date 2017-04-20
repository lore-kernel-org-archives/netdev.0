From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dp83640: don't recieve time stamps twice
Date: Thu, 20 Apr 2017 16:02:27 -0400 (EDT)
Message-ID: <20170420.160227.1855463512293087492.davem@davemloft.net>
References: <20170418191426.GA17838@mwanda>
        <1492593414.3108.1.camel@spectralink.com>
        <20170419103135.GA1670@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Stefan.Sorensen@spectralink.com, dan.carpenter@oracle.com,
        netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        kernel-janitors@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947280AbdDTUC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:02:29 -0400
In-Reply-To: <20170419103135.GA1670@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 19 Apr 2017 12:31:35 +0200

> On Wed, Apr 19, 2017 at 09:16:56AM +0000, Sørensen, Stefan wrote:
>> You are correct that these lines was added accidentally.
> 
> Can we please fix this in another way?  There is no need to hold the
> spin lock during the callback into the networking stack.  Instead, how
> about the following diff, which also fixes the other call site...

Oops, I read this too late.

I already applied and pushed out Dan's fix.
