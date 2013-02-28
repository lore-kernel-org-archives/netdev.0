From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 20:25:00 +0100
Message-ID: <CACna6rzL_7Kmkrh0y1R7TPWqEAZ+ANa7cSnUumF9bDmWUs-6rA@mail.gmail.com>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
	<CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
	<20130228.142142.242861205295035084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hauke@hauke-m.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:55753 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab3B1TZA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 14:25:00 -0500
Received: by mail-oa0-f49.google.com with SMTP id j6so4235135oag.8
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 11:25:00 -0800 (PST)
In-Reply-To: <20130228.142142.242861205295035084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/28 David Miller <davem@davemloft.net>:
> From: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date: Thu, 28 Feb 2013 18:57:03 +0100
>
>> 2013/2/28 Hauke Mehrtens <hauke@hauke-m.de>:
>>> Do not include the frame check sequence when adding the skb to
>>> netif_receive_skb(). This causes problems when this interface was
>>> bridged to a wifi ap and a big package should be forwarded from thi=
s
>>> Ethernet driver through a bride to the wifi client.
>>
>> Is this a real fix?
>>
>> Don't get me wrong, but it sounds a little like a workaround for som=
e
>> issue in another network layer ;)
>
> FCS should never be included in the SKB unless a specific debugging
> configuration knob has enabled it.
>
> Having the FCS there will screw up things like device provided partia=
l
> checksums (CHECKSUM_PARTIAL), which operate over the entire contents
> of the packet starting at a particular offset, so if the FCS is there
> we'll include it.
>
> This change is therefore about as correct as can possibly be.

OK, thanks! :)

--=20
Rafa=C5=82
