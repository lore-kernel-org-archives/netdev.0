From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] geneve: add missing rx stats accounting
Date: Thu, 08 Jun 2017 19:29:24 -0400 (EDT)
Message-ID: <20170608.192924.2074577502421829651.davem@davemloft.net>
References: <1496947189-19773-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdFHX30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:29:26 -0400
In-Reply-To: <1496947189-19773-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Thu,  8 Jun 2017 11:39:49 -0700

> +			++geneve->dev->stats.rx_dropped;

Please use the more canonical post-increment "x++"

Please do this in your entire patch.

Thanks.
