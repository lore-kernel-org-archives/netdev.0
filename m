From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: cwnd does not increase in TCP YeAH
Date: Thu, 08 Sep 2016 17:16:42 -0700 (PDT)
Message-ID: <20160908.171642.656826696713730257.davem@davemloft.net>
References: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
        <20160906.135846.2108420188600081714.davem@davemloft.net>
        <b4685d52-7fa0-5fac-b361-a20b610674d7@anchorfree.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com, d.adamushko@anchorfree.com
To: agermanov@anchorfree.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcIIAQo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:16:44 -0400
In-Reply-To: <b4685d52-7fa0-5fac-b361-a20b610674d7@anchorfree.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artem Germanov <agermanov@anchorfree.com>
Date: Wed, 7 Sep 2016 10:49:36 -0700

> Commit 76174004a0f19785a328f40388e87e982bbf69b9
> (tcp: do not slow start when cwnd equals ssthresh )
> introduced regression in TCP YeAH. Using 100ms delay 1% loss virtual 
> ethernet link kernel 4.2 shows bandwidth ~500KB/s for single TCP 
> connection and kernel 4.3 and above (including 4.8-rc4) shows bandwidth 
> ~100KB/s.
>    That is caused by stalled cwnd when cwnd equals ssthresh. This patch 
> fixes it by proper increasing cwnd in this case.
> 
> Signed-off-by: Artem Germanov <agermanov@anchorfree.com>
> Acked-by: Dmitry Adamushko <d.adamushko@anchorfree.com>

Applied and queued up for -stable, thanks.
