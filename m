From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH 1/1] net: Set NOCARRIER bit of etherdev state at initialization
Date: Sat, 24 May 2014 18:52:15 +0530
Message-ID: <CAHPKR9LUseeYbtJomZHSu0mmU-VbcCVg8OGnSCOL1b1=Sfj9kQ@mail.gmail.com>
References: <537F7EEF.3060701@gmail.com>
	<1400866681.18322.27.camel@dcbw.local>
	<20140523.141551.1253983630587935706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: dcbw@redhat.com, stephen@networkplumber.org,
	Avinash Kumar <avi.kp.137@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:58062 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaEXNWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 09:22:17 -0400
Received: by mail-wi0-f175.google.com with SMTP id f8so2104253wiw.2
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 06:22:15 -0700 (PDT)
In-Reply-To: <20140523.141551.1253983630587935706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 11:45 PM, David Miller <davem@davemloft.net> wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Fri, 23 May 2014 12:38:01 -0500
>
>> The current "carrier on until told otherwise" model is intentional,
>> because not all drivers support carrier detection, and thus we must
>> assume the carrier is on until the driver tells us it is not on.
>>
>> Would this patch break that model?
>
> Absolutely correct, this change is completely inappropriate.

So it is driver's responsibility to maintain this flag appropriately.
Thus if a driver supports carrier detection, it should set "carrier
on" only after determining the carrier state. Then I'll add
'netif_carrier_off' call to smsc911x driver and send a new patch.

Thanks for the explanation.

Regards,
K.Balakumaran
