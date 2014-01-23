From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 4/4] net: phy: remove unneeded parenthesis
Date: Thu, 23 Jan 2014 14:39:13 -0800
Message-ID: <CAGVrzcan4pJ7=TxTf26c08ct1q9SpdLNm_DyyHTe_=3EW3pjEw@mail.gmail.com>
References: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
 <1390508269-28769-5-git-send-email-f.fainelli@gmail.com> <52E199AA.7020200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Joe Perches <joe@perches.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:41702 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaAWWjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:39:54 -0500
Received: by mail-pb0-f48.google.com with SMTP id rr13so2432227pbb.35
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 14:39:53 -0800 (PST)
In-Reply-To: <52E199AA.7020200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/23 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 24-01-2014 0:17, Florian Fainelli wrote:
>
>> Our if/else statement in phy_print_status() is only comprised of one
>> line for each, remove the parenthesis.
>
>
>    I protest, the *if* arm is multi-line, though single statement. :-)
> Could we avoid changing that code to and fro during 3.14-rc1?

Is it that big of a problem? Does that make checkpatch.pl unhappy,
does that make you unhappy? Since this is intentionally the last patch
in the series, it would be trivial for David to ignore it I suppose.

>
>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>   drivers/net/phy/phy.c | 5 ++---
>>   1 file changed, 2 insertions(+), 3 deletions(-)
>
>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index 36fc6e1..59aa85e 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -64,15 +64,14 @@ static const char *phy_speed_to_str(int speed)
>>    */
>>   void phy_print_status(struct phy_device *phydev)
>>   {
>> -       if (phydev->link) {
>> +       if (phydev->link)
>>                 netdev_info(phydev->attached_dev,
>>                         "Link is Up - %s/%s - flow control %s\n",
>>                         phy_speed_to_str(phydev->speed),
>>                         DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
>>                         phydev->pause ? "rx/tx" : "off");
>> -       } else  {
>> +       else
>>                 netdev_info(phydev->attached_dev, "Link is Down\n");
>> -       }
>>   }
>>   EXPORT_SYMBOL(phy_print_status);
>
>
> WBR, Sergei
>



-- 
Florian
