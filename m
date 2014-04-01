From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 1 Apr 2014 12:59:45 -0700
Message-ID: <CAGVrzcaRci3Q871NOc_BLQf81dyWjwWxgE5HgT_V1GtJToG7YA@mail.gmail.com>
References: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
 <1396375445.21529.95.camel@joe-AO722> <62eb4c507b904928a6b5891113153f18@DM2PR03MB365.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Emilian Medve <Emilian.Medve@freescale.com>
To: Shruti Kanetkar <Shruti@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:54252 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaDAUA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:00:26 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so10030443pdj.31
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 13:00:25 -0700 (PDT)
In-Reply-To: <62eb4c507b904928a6b5891113153f18@DM2PR03MB365.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shruti,

2014-04-01 12:53 GMT-07:00 Shruti Kanetkar <Shruti@freescale.com>:
> Hello Joe,
>
> Thank you for sharing the script.
> I shall give it a try and credit you for the script.

Can you run this spatch throughout the drivers/net/phy/ files to begin
with and see what interesting results it produces?

Thanks!

>
>> -----Original Message-----
>> From: Joe Perches [mailto:joe@perches.com]
>> Sent: Tuesday, April 01, 2014 1:04 PM
>> To: Kanetkar Shruti-B44454
>> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; Medve Emilian-EMMEDVE1
>> Subject: Re: [PATCH] net/phy: Remove return value for a void function
>>
>> Here's a spatch script for this:
>>
>> $ cat void_return.cocci
>> @@
>> identifier func;
>> expression S;
>> @@
>> void func(...) {
>> ...
>>       if (...)
>> -             return S;
>> +             { S; return; }
>> ...
>> }
>>
>> @@
>> identifier func;
>> expression S;
>> @@
>> void func(...) {
>> ...
>>       if (...) {
>> ...
>> -             return S;
>> +             S;
>>       }
>> ...
>> }
>>
>> @@
>> identifier func;
>> expression S;
>> @@
>> void func(...) {
>> ...
>> -     return S;
>> +     S;
>> }
>>
>>
>>
>
> Regards,
> Shruti



-- 
Florian
