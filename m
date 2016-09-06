From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt_en: Fix TX push operation on ARM64.
Date: Tue, 06 Sep 2016 13:59:38 -0700 (PDT)
Message-ID: <20160906.135938.352826375123342090.davem@davemloft.net>
References: <1473055055-28605-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964864AbcIFU7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:59:39 -0400
In-Reply-To: <1473055055-28605-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon,  5 Sep 2016 01:57:35 -0400

> There is a code path where we are calling __iowrite64_copy() on
> an address that is not 64-bit aligned.  This causes an exception on
> some architectures such as arm64.  Fix that code path by using
> __iowrite32_copy().
> 
> Reported-by: JD Zheng <jiandong.zheng@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied and queued up for -stable, thanks.
