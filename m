From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-RESEND] vhost-vsock: fix orphan connection reset
Date: Thu, 08 Dec 2016 21:25:03 -0500 (EST)
Message-ID: <20161208.212503.1982293102523713728.davem@davemloft.net>
References: <1481217046-7058-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: bergwolf@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932502AbcLICZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 21:25:05 -0500
In-Reply-To: <1481217046-7058-1-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peng Tao <bergwolf@gmail.com>
Date: Fri,  9 Dec 2016 01:10:46 +0800

> local_addr.svm_cid is host cid. We should check guest cid instead,
> which is remote_addr.svm_cid. Otherwise we end up resetting all
> connections to all guests.
> 
> Cc: stable@vger.kernel.org [4.8+]
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>

Applied and queued up for -stable, thanks.
