From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Mon, 6 Jun 2011 17:48:39 +0200
Message-ID: <BANLkTimuZHNfGjEu0v7V8uHqMWHF24794Q@mail.gmail.com>
References: <1306288567-1773-1-git-send-email-maheshb@google.com>
 <1306363336-13614-1-git-send-email-maheshb@google.com> <20110604.133438.1450652272927306428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:59992 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899Ab1FFPtA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 11:49:00 -0400
Received: by qyg14 with SMTP id 14so2011152qyg.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 08:48:59 -0700 (PDT)
In-Reply-To: <20110604.133438.1450652272927306428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/4 David Miller <davem@davemloft.net>:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Wed, 25 May 2011 15:42:16 -0700
>> Little bit cleanup by defining enum for all bits used. Also use thos=
e enum
>> values to redefine flags.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> Changes since v2:
>> =C2=A0(1) Removed the include which was part of the other patch (spl=
it mishap).
>> =C2=A0(2) Changed the enums to add NETIF_F_ prefix.
>
> I hate to be a pain after you've put so much work into these patches,
> but I simply don't like this approach.
>
> I think the abstracted interfaces should come first. =C2=A0You don't =
need to
> change any of the NETIF_F_* defines in order to do that. =C2=A0You sh=
ould only
> need to add the netdev_{set,clear,test}_*() macros.

I suggested that it's better to first introduce the enum because it
can be used right away (e.g. in ethtool.c feature name table).
Whatever the new access scheme will be, it will also use that enum.

Best Regards,
Micha=C5=82 Miros=C5=82aw
