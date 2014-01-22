From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: use network device in phy_print_status
Date: Wed, 22 Jan 2014 11:45:36 -0800
Message-ID: <CAGVrzcYUrctOhomjO-iGK_jsJOCtdALrhjDPcZvdZ5LDTd8mvA@mail.gmail.com>
References: <1390415553-4961-1-git-send-email-f.fainelli@gmail.com>
 <1390416584.31946.84.camel@joe-AO722> <CAGVrzcaDTOxBHNgSF1wme8JgnYV-KjpNfqqcNLdebqR0hjnWJg@mail.gmail.com>
 <1390417506.31946.89.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:57455 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbaAVTqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 14:46:17 -0500
Received: by mail-pd0-f177.google.com with SMTP id x10so788934pdj.22
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 11:46:16 -0800 (PST)
In-Reply-To: <1390417506.31946.89.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/22 Joe Perches <joe@perches.com>:
> On Wed, 2014-01-22 at 10:52 -0800, Florian Fainelli wrote:
>> 2014/1/22 Joe Perches <joe@perches.com>:
>> > On Wed, 2014-01-22 at 10:32 -0800, Florian Fainelli wrote:
>> >> phy_print_status() currently uses dev_name(&phydev->dev) which will
>> >> usually result in printing something along those lines for Device Tree
>> >> aware drivers:
>> >>
>> >> libphy: f0b60000.etherne:0a - Link is Down
>> >> libphy: f0ba0000.etherne:00 - Link is Up - 1000/Full
> []
>> > The leading "- "'s now aren't useful and these could be
>>
>> I did not want to remove the leading "- " since this would sort of
>> produce a very different message now, that said, I have no strong
>> feeling removing it.
>
> The output would already be different as it's no longer
> prefixed by "phylib: ".
>
> With the dash it'll look like:
>
> r8169 0000:01:00.0 eth3: - Link is Up
>
> when all the other netdev_info link messages
> don't use the - separator after the "ethX: "

You are right, thanks for spotting that, I will re-submit.

>
>> > It may also be possible to slightly improve the output by
>> > reducing the number of 0's in the speed block and emitting
>> > Kb/Mb/Gb (or Kbps/Mbps/Gbps) and maybe flow control if it's
>> > available.
>>
>> Sure thing, that calls for a follow-up patch though.
>
> Thanks.
>
-- 
Florian
