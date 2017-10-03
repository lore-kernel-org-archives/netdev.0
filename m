From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: rtnetlink: fix info leak in RTM_GETSTATS call
Date: Tue, 03 Oct 2017 10:19:18 -0700 (PDT)
Message-ID: <20171003.101918.592253533156020512.davem@davemloft.net>
References: <1507026048-13734-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keescook@chromium.org, dvyukov@google.com,
        andreyknvl@google.com, kcc@google.com, roopa@cumulusnetworks.com,
        glider@google.com, edumazet@google.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdJCRTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:19:19 -0400
In-Reply-To: <1507026048-13734-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue,  3 Oct 2017 13:20:48 +0300

> When RTM_GETSTATS was added the fields of its header struct were not all
> initialized when returning the result thus leaking 4 bytes of information
> to user-space per rtnl_fill_statsinfo call, so initialize them now. Thanks
> to Alexander Potapenko for the detailed report and bisection.
> 
> Reported-by: Alexander Potapenko <glider@google.com>
> Fixes: 10c9ead9f3c6 ("rtnetlink: add new RTM_GETSTATS message to dump link stats")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
