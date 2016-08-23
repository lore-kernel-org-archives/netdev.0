From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] alx: add tso support
Date: Tue, 23 Aug 2016 16:24:24 -0700 (PDT)
Message-ID: <20160823.162424.1499120284925620302.davem@davemloft.net>
References: <1471983681-5661-1-git-send-email-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55731 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbcHWXYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:24:25 -0400
In-Reply-To: <1471983681-5661-1-git-send-email-tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Tue, 23 Aug 2016 22:21:21 +0200

> @@ -993,6 +993,18 @@ static void alx_reset(struct work_struct *work)
>  	rtnl_unlock();
>  }
>  
> +static inline int alx_tpd_req(struct sk_buff *skb)
> +{

Please don't use inline for functions in foo.c files, let the compiler
decide.

Thanks.
