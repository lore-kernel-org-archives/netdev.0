From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix overrun in sctp_diag_dump_one()
Date: Tue, 23 Aug 2016 17:23:25 -0700 (PDT)
Message-ID: <20160823.172325.1181752363755678623.davem@davemloft.net>
References: <1471966852-6218-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56067 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754000AbcHXAX0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:23:26 -0400
In-Reply-To: <1471966852-6218-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Tue, 23 Aug 2016 11:40:52 -0400

> The function sctp_diag_dump_one() currently performs a memcpy()
> of 64 bytes from a 16 byte field into another 16 byte field. Fix
> by using correct size, use sizeof to obtain correct size instead
> of using a hard-coded constant.
> 
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied and queued up for -stable, thanks.
