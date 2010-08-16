From: Morgon.J.Kanter@Dartmouth.edu
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Sun, 15 Aug 2010 20:43:50 -0400
Message-ID: <20100815204350.4amjt1lngg0s0048@webmail.dartmouth.edu>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
	<20100814.223532.242143460.davem@davemloft.net>
	<20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
	<20100815.131359.191392588.davem@davemloft.net>
	<1281905220.2942.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spruis.dartmouth.edu ([129.170.208.37]:53463 "EHLO
	spruis.dartmouth.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775Ab0HPAnv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 20:43:51 -0400
In-Reply-To: <1281905220.2942.57.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric Dumazet <eric.dumazet@gmail.com>:
> Le dimanche 15 ao=C3=BBt 2010 =C3=A0 13:13 -0700, David Miller a =C3=A9=
crit :
>> From: Morgon.J.Kanter@Dartmouth.edu
>> Date: Sun, 15 Aug 2010 13:57:41 -0400
>>
>> > Is there a way to turn this behavior off, then, with raw sockets? =
Zero
>> > is the desired ID value.
>>
>> No, there isn't.
>
> Just a note about IP_DF (Dont Fragment) bit.
>
> If set, ID stay 0.
>
> Not sure it can help Morgon.
>
> Jiri Olsa added IP_NODEFRAG option some weeks ago (commit 7b2ff18e),
> we probably could implement IP_NOIDENT option for RAW sockets ?

Thanks for the information. I was thinking of adding it in as a socket =
=20
option as well, similar to that one you pointed out -- but seeing that =
=20
makes me wonder, perhaps an "as-is" option would be more appropriate, =20
instead of a different option for each field you want to leave as-is?

Thanks,
-- Morgon
