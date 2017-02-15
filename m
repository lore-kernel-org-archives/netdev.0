From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH net-next 10/13] net: ethernet: aquantia: Checking for
 success dma_map_single.
Date: Thu, 16 Feb 2017 00:47:19 +0300
Message-ID: <12285b20-c695-3786-a681-1223887258e4@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <6ad9fef330a2c9b59139621efbb7c77e746d9f25.1487187192.git.pavel.belous@aquantia.com>
 <60f99adb-f29f-1527-0a0a-406c39c99d0f@gmx.de>
 <f52f06ff-0666-865a-74b5-e7840fde3a3c@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0069.outbound.protection.outlook.com ([104.47.41.69]:40661
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752201AbdBOVri (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:47:38 -0500
In-Reply-To: <f52f06ff-0666-865a-74b5-e7840fde3a3c@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I will fix it in the patch v2.

Thank you.

Regards,
Pavel

On 16.02.2017 00:40, Lino Sanfilippo wrote:
> On 15.02.2017 22:23, Lino Sanfilippo wrote:
>
>>
>>
>> In case of this error you have to undo all mappings that you have
>> done so far (i.e the complete frag list and the head buffer).
>>
>
> And, since mapping failed, set ret = 0 and handle this case in the
> caller, too.
>
> Regards,
> Lino
>
