From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH net-next v2 11/12] net: ethernet: aquantia: Fixed memory
 allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Sat, 18 Feb 2017 19:33:31 +0300
Message-ID: <379a53af-55cc-e409-3689-58445c084123@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
 <20170217224353.GP6096@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0064.outbound.protection.outlook.com ([104.47.34.64]:56832
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753035AbdBRQdu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 11:33:50 -0500
In-Reply-To: <20170217224353.GP6096@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2017 01:43 AM, Andrew Lunn wrote:
>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
>> index 4c40644..0877625 100644
>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
>> @@ -278,6 +278,8 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
>>  	struct aq_ring_buff_s *buff = NULL;
>>  	int err = 0;
>>  	int i = 0;
>> +	unsigned int pages_order = fls(AQ_CFG_RX_FRAME_MAX / PAGE_SIZE +
>> +		(AQ_CFG_RX_FRAME_MAX % PAGE_SIZE ? 1 : 0)) - 1;
>
> Reverse Christmas tree?
>
> 	Andrew
>

Thank you.
I will fix it in v3.

Regards,
Pavel
