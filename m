From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/8] Introduce ife encapsulation module
Date: Thu, 10 Nov 2016 14:17:31 -0500 (EST)
Message-ID: <20161110.141731.1693686577994851858.davem@davemloft.net>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
        <1478776988-5400-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934979AbcKJTSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 14:18:00 -0500
In-Reply-To: <1478776988-5400-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 10 Nov 2016 12:23:01 +0100

> +void *ife_encode(struct sk_buff *skb, u16 metalen)

metalen is u16

> +	metalen = htons(metalen);

htons() returns be16.

> +int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
> +{
> +	u32 *tlv = (u32 *) (skbdata);
 ...
> +	*tlv = htonl(htlv);

Similar situation here.
