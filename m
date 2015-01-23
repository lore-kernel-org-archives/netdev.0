From: Jamal Mohammad <md.jamalmohiuddin@gmail.com>
Subject: Re: [PATCH] net: ieee802154: cc2520: Fix coding style issues
Date: Fri, 23 Jan 2015 18:14:54 +0530
Message-ID: <CAP8vtKJnGE3=UM+XV5DgMvTXNGXFsX_D-c0u7nDoYhTXVJaR4Q@mail.gmail.com>
References: <1422005180-13230-1-git-send-email-md.jamalmohiuddin@gmail.com>
	<54C2409A.6020506@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	Alexander Aring <alex.aring@gmail.com>,
	linux-wpan - ML <linux-wpan@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:55500 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbbAWMoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 07:44:55 -0500
In-Reply-To: <54C2409A.6020506@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 6:07 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 1/23/2015 12:26 PM, Mohammad Jamal wrote:
>
>> This patch solves the coding style issues such as space after ,
>
>
>    s/after/before/?
>
>> and removes the blank lines
>
>
>   Extra blank lines, you mean?
>
>> Signed-off-by: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
>> ---
>>   drivers/net/ieee802154/cc2520.c |    6 ++----
>>   1 file changed, 2 insertions(+), 4 deletions(-)
>
>
>> diff --git a/drivers/net/ieee802154/cc2520.c
>> b/drivers/net/ieee802154/cc2520.c
>> index f9df9fa..dd129be 100644
>> --- a/drivers/net/ieee802154/cc2520.c
>> +++ b/drivers/net/ieee802154/cc2520.c
>
> [...]
>>
>> @@ -551,14 +550,14 @@ cc2520_ed(struct ieee802154_hw *hw, u8 *level)
>>         u8 rssi;
>>         int ret;
>>
>> -       ret = cc2520_read_register(priv , CC2520_RSSISTAT, &status);
>> +       ret = cc2520_read_register(priv, CC2520_RSSISTAT, &status);
>>         if (ret)
>>                 return ret;
>>
>>         if (status != RSSI_VALID)
>>                 return -EINVAL;
>>
>> -       ret = cc2520_read_register(priv , CC2520_RSSI, &rssi);
>> +       ret = cc2520_read_register(priv, CC2520_RSSI, &rssi);
>
> [...]
>
> WBR, Sergei
>

Sorry for that,

i actually have cloned and linus torvalds git and when i ran
checkpatch.pl i have found some warnings. so this patch was removing
those warnings...as bhadram told that these warnings are already
removed in bluetooth-next tree...so this patch any how fails....
