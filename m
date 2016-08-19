From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fixes resource allocation for ULD's in
 kdump kernel
Date: Thu, 18 Aug 2016 23:10:37 -0700 (PDT)
Message-ID: <20160818.231037.1138297383989318790.davem@davemloft.net>
References: <1471423168-7354-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42325 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752675AbcHSGLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:11:22 -0400
In-Reply-To: <1471423168-7354-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 17 Aug 2016 14:09:28 +0530

> At present the code to check in kdump kernel was not disabling
> allocation of resources when CONFIG_CHELSIO_T4_DCB is defined, move the
> code outside #defines so that it gets disabled irrespective of #define,
> when in kdump kernel.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
