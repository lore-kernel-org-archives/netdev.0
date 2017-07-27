From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix a memleak for dccp_feat_init err process
Date: Thu, 27 Jul 2017 00:01:38 -0700 (PDT)
Message-ID: <20170727.000138.786490802662921726.davem@davemloft.net>
References: <62b8165447ec57830c1199af42a3490d896fbc26.1501050015.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbdG0HBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:01:38 -0400
In-Reply-To: <62b8165447ec57830c1199af42a3490d896fbc26.1501050015.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 26 Jul 2017 14:20:15 +0800

> In dccp_feat_init, when ccid_get_builtin_ccids failsto alloc
> memory for rx.val, it should free tx.val before returning an
> error.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Also applied and queued up for -stable.

Thanks.
