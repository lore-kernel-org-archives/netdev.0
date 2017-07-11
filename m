From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: Bug fixes.
Date: Tue, 11 Jul 2017 10:32:55 -0700 (PDT)
Message-ID: <20170711.103255.375286747479467703.davem@davemloft.net>
References: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932401AbdGKRc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:32:58 -0400
In-Reply-To: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 11 Jul 2017 13:05:33 -0400

> 3 bug fixes in this series.  Fix a crash in bnxt_get_stats64() that can
> happen if the device is closing and freeing the statistics block at the
> same time.  The 2nd one fixes ethtool -L failing when changing from
> combined to non-combined mode or vice versa.  The last one fixes SRIOV
> failure on big-endian systems because we were setting a bitmap wrong in
> a firmware message.

Series applied, thanks Michael.

We really should look into generically taking care of the ->ndo_close()
vs. statistics pulling synchronization so that every driver doesn't
need to have code like this.
