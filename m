From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cwnd does not increase in TCP YeAH
Date: Tue, 06 Sep 2016 13:58:46 -0700 (PDT)
Message-ID: <20160906.135846.2108420188600081714.davem@davemloft.net>
References: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com
To: agermanov@anchorfree.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935484AbcIFU6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:58:48 -0400
In-Reply-To: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artem Germanov <agermanov@anchorfree.com>
Date: Sun, 4 Sep 2016 21:03:27 -0700

> Commit 76174004a0f19785a328f40388e87e982bbf69b9
> (tcp: do not slow start when cwnd equals ssthresh )
> introduced regression in TCP YeAH. Using 100ms delay 1% loss virtual
> ethernet link kernel 4.2 shows bandwidth ~500KB/s for single TCP
> connection and kernel 4.3 and above (including 4.8-rc4) shows
> bandwidth ~100KB/s.
>  That is caused by stalled cwnd when cwnd equals ssthresh. This patch
>  fixes it by proper increasing cwnd in this case.
> 
> Signed-off-by: Artem Germanov <agermanov@anchorfree.com>

This patch won't apply properly.

First, it isn't rooted properly.

Second, all the TAB characters have been mangled into spaces.

Please fix these problems, send a test patch to yourself, and only
resubmit this patch when you can successfully apply that test patch.

Thank you.
