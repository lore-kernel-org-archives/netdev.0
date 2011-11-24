From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording send/compl
Date: Thu, 24 Nov 2011 08:30:26 +0100
Message-ID: <CAA93jw6OuuUhSMMnmX3k2=+HB3A92X3CrvfbPHDGV=0fbS-YOA@mail.gmail.com>
References: <20111123094614.36560215@nehalam.linuxnetplumber.net>
	<20111123.185812.1721878183759040757.davem@davemloft.net>
	<20111123160320.76143e3b@nehalam.linuxnetplumber.net>
	<20111123.190623.2026426589805797580.davem@davemloft.net>
	<CA+mtBx-VSJ6U2SyUxQt7eK9+cXFFAEQXgmhc+yWwpTX8zd6TJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:43132 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab1KXHa1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 02:30:27 -0500
Received: by qyd20 with SMTP id 20so986346qyd.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 23:30:26 -0800 (PST)
In-Reply-To: <CA+mtBx-VSJ6U2SyUxQt7eK9+cXFFAEQXgmhc+yWwpTX8zd6TJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 1:32 AM, Tom Herbert <therbert@google.com> wrot=
e:
>>> I was referring to the transmit routine, there for netdev_sent_queu=
e()
>>> is always called with one packet.
>>
>> Optimism for the future? :-)
>>
>
> Yep, I am looking forward to the day that someone figures out how to
> batch transmits in a meaningful way!

I liked it in potentia, as wireless likes to aggregate packets into
batches that fit into an AMPDU directed at a single station
and/or TXOP.

not that BQL can help there at present as this happens below the
mac80211 layer, and packets vanish once consumed by the driver.

>
>> But yeah if nobody batches right now, no reason to support this in t=
he
>> interfaces, we can add it later.
>
> Okay.
>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
