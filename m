From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/2] pptp: Use macro and sizeof instead of literal
 number
Date: Fri, 19 Aug 2016 14:31:28 -0700 (PDT)
Message-ID: <20160819.143128.561754527412577407.davem@davemloft.net>
References: <1471495654-20134-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55348 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755321AbcHSVja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 17:39:30 -0400
In-Reply-To: <1471495654-20134-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu, 18 Aug 2016 12:47:34 +0800

> @@ -54,6 +54,8 @@ static struct proto pptp_sk_proto __read_mostly;
>  static const struct ppp_channel_ops pptp_chan_ops;
>  static const struct proto_ops pptp_ops;
>  
> +static const u8 fixed_ppphdr[2] = {PPP_ALLSTATIONS, PPP_UI};
> +

This makes things much worse in my opinion, and at the cost
of two extra bytes in the data section as well.

I'm not applying this.
