From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Wed, 5 Oct 2016 15:57:57 +0300
Message-ID: <d3baf861-b319-af95-8e0e-2c0cae1f071b@cogentembedded.com>
References: <1475671572.6101.7.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, john@phrozen.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33815 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752015AbcJEM6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 08:58:02 -0400
Received: by mail-lf0-f46.google.com with SMTP id b81so91173694lfe.1
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 05:58:00 -0700 (PDT)
In-Reply-To: <1475671572.6101.7.camel@mtksdaap41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2016 03:46 PM, Nelson Chang wrote:

>> +static bool mtk_is_hwlro_supported(struct mtk_eth *eth) {
>> +     if (eth->chip_id == MT7623_ETH)
>> +             return true;
>> +     else
>> +             return false;
>
>         return eth->chip_id == MT7623_ETH;
>
> => Since there will be more chips support hw lro in the future, keep the
> original codes to have the scalability like this:
> if (eth->chip_id == MTxxxx_ETH ||
>     eth->chip_id == MTyyyy_ETH ||
>     ....)
> 	return true;

    Then use *switch*, not *if*.

> Nelson

MBR, Sergei
