From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] VSOCK: remove unnecessary ternary operator on
 return value
Date: Thu, 30 Mar 2017 11:07:28 -0700 (PDT)
Message-ID: <20170330.110728.1080980088987923914.davem@davemloft.net>
References: <20170329153355.17525-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhansen@vmware.com, mst@redhat.com, aditr@vmware.com,
        georgezhang@vmware.com, stefanha@redhat.com, julia.lawall@lip6.fr,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934480AbdC3SHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 14:07:30 -0400
In-Reply-To: <20170329153355.17525-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 29 Mar 2017 16:33:55 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Rather than assign the positive errno values to ret and then
> checking if it is positive and flip the sign, just return the
> errno value.
> 
> Detected by CoverityScan, CID#986649 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
