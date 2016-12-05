From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH V2 net 05/20] net/ena: fix RSS default hash configuration
Date: Mon, 5 Dec 2016 20:32:58 +0200
Message-ID: <c52791ad-0d14-164e-b03f-0883247ae3b3@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-6-git-send-email-netanel@annapurnalabs.com>
 <20161205042028.GF4310@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Matt Wilson <msw@amzn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37786 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752187AbcLESeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:34:37 -0500
Received: by mail-wm0-f50.google.com with SMTP id t79so102385952wmt.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:33:03 -0800 (PST)
In-Reply-To: <20161205042028.GF4310@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/05/2016 06:20 AM, Matt Wilson wrote:
> On Sun, Dec 04, 2016 at 03:19:23PM +0200, Netanel Belgazal wrote:
>> ENA default hash configure IPv4_frag hash twice instead of
> configure -> configures. You may want to include "erroneously". What
> is the consequence of this bug?
I'll fix and I'll add explain the effect of this bug.

>
>> configure non ip packets.
> configuring non-IP packets.

OK.
>
> --msw
>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
>> ---
>>   drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
>> index 3066d9c..46aad3a 100644
>> --- a/drivers/net/ethernet/amazon/ena/ena_com.c
>> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c
>> @@ -2184,7 +2184,7 @@ int ena_com_set_default_hash_ctrl(struct ena_com_dev *ena_dev)
>>   	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
>>   		ENA_ADMIN_RSS_L3_SA | ENA_ADMIN_RSS_L3_DA;
>>   
>> -	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
>> +	hash_ctrl->selected_fields[ENA_ADMIN_RSS_NOT_IP].fields =
>>   		ENA_ADMIN_RSS_L2_DA | ENA_ADMIN_RSS_L2_SA;
>>   
>>   	for (i = 0; i < ENA_ADMIN_RSS_PROTO_NUM; i++) {
