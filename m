From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] ISDN: eicon: switch to use native bitmaps
Date: Tue, 04 Jul 2017 03:41:35 -0700 (PDT)
Message-ID: <20170704.034135.1806741431884009078.davem@davemloft.net>
References: <20170704103451.52654-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbdGDKlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 06:41:39 -0400
In-Reply-To: <20170704103451.52654-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue,  4 Jul 2017 13:34:51 +0300

> Two arrays are clearly bit maps, so, make that explicit by converting to
> bitmap API and remove custom helpers.
> 
> Note sig_ind() uses out of boundary bit to (looks like) protect against
> potential bitmap_empty() checks for the same bitmap.
> 
> This patch removes that since:
> 1) that didn't guarantee atomicity anyway;
> 2) the first operation inside the for-loop is set bit in the bitmap
>    (which effectively makes it non-empty);
> 3) group_optimization() doesn't utilize possible emptiness of the bitmap
>    in question.
> 
> Thus, if there is a protection needed it should be implemented properly.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

net-next is closed, please submit this when net-next opens back up.

Thank you.
