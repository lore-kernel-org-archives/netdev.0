From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] qed: Fix to use list_for_each_entry_safe() when
 delete items
Date: Thu, 13 Oct 2016 09:58:02 -0400 (EDT)
Message-ID: <20161013.095802.1988627112670234693.davem@davemloft.net>
References: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
        <1476108508-14376-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        weiyongjun1@huawei.com, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932516AbcJMN7Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:59:25 -0400
In-Reply-To: <1476108508-14376-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 10 Oct 2016 14:08:28 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Since we will remove items off the list using list_del() we need
> to use a safe version of the list_for_each_entry() macro aptly named
> list_for_each_entry_safe().
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> Acked-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
> ---
> v1 -> v2: use tmp_buffer instead of tmp

Applied, thanks.
