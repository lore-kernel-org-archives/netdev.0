From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC(v2) net-next 13/13] ipv6: Complete neighbour entry removal
 from dst_entry.
Date: Wed, 16 Jan 2013 15:09:19 +0800
Message-ID: <50F6521F.4020706@gmail.com>
References: <50F587ED.5070602@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:63606 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758242Ab3APHJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 02:09:26 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so444508dae.7
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 23:09:26 -0800 (PST)
In-Reply-To: <50F587ED.5070602@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
> +#if 0
>   		if (rt->n && rt->n->dev == dev) {
>   			rt->n->dev = loopback_dev;
>   			dev_hold(loopback_dev);
>   			dev_put(dev);
>   		}
> +#endif

Why commenting this out instead of removing it? As rt->n is totally
removed, how possible could we reuse this code in future?

Thanks.
