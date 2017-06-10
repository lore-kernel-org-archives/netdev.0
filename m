From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] sctp: no need to check assoc id before
 calling sctp_assoc_set_id
Date: Sat, 10 Jun 2017 16:23:57 -0400 (EDT)
Message-ID: <20170610.162357.1913351871329909555.davem@davemloft.net>
References: <ea556c7733c5bf63532ce35186e4bc7a519bf858.1497079632.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdFJUX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:23:59 -0400
In-Reply-To: <ea556c7733c5bf63532ce35186e4bc7a519bf858.1497079632.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 10 Jun 2017 15:27:12 +0800

> sctp_assoc_set_id does the assoc id check in the beginning when
> processing dupcookie, no need to do the same check before calling
> it.
> 
> v1->v2:
>   fix some typo errs Marcelo pointed in changelog.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Also applied, thanks.
