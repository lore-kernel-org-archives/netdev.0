From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH net-next v2 11/12] net: ethernet: aquantia: Fixed memory
 allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Sat, 18 Feb 2017 19:44:25 +0300
Message-ID: <90916afc-6aca-de78-6e49-84462a0a5a46@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
 <a793e89b-d1e2-5cec-cae6-b223c7f8f708@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0071.outbound.protection.outlook.com ([104.47.40.71]:21632
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753357AbdBRRUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 12:20:16 -0500
In-Reply-To: <a793e89b-d1e2-5cec-cae6-b223c7f8f708@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/18/2017 02:50 PM, Lino Sanfilippo wrote:
> Hi,
>
> On 17.02.2017 22:07, Pavel Belous wrote:
>> From: Pavel Belous <pavel.belous@aquantia.com>
>>
>> We should allocate the number of pages based on the config parameter
>> AQ_CFG_RX_FRAME_MAX.
>>
>> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
>
>>  	do {
>>  		if (spin_trylock(&ring->header.lock)) {
>> -			frags = aq_nic_map_skb(self, skb, &buffers[0]);
>> +			frags = aq_nic_map_skb(self, skb, buffers);
>>
>> -			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
>> +			aq_ring_tx_append_buffs(ring, buffers, frags);
>>
>
> This change has nothing to do with what the commit message claims that the
> patch is about. Please dont mix fixes and totally unrelated cleanups in one
> patch.
>
> Regards,
> Lino
>

Sorry, its just small fix for readability.
I will remove it or put in separate patch in v3.

Regards,
Pavel
