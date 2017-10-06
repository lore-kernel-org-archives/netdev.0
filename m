From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selftests/net: rxtimestamp: Fix an off by one
Date: Thu, 05 Oct 2017 21:29:36 -0700 (PDT)
Message-ID: <20171005.212936.1533429317037705562.davem@davemloft.net>
References: <20171005125347.otplfss4mo7hfopv@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuah@kernel.org, maloney@google.com, willemb@google.com,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdJFE3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:29:37 -0400
In-Reply-To: <20171005125347.otplfss4mo7hfopv@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Oct 2017 15:53:47 +0300

> The > should be >= so that we don't write one element beyond the end of
> the array.
> 
> Fixes: 16e781224198 ("selftests/net: Add a test to validate behavior of rx timestamps")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
