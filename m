From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-ipv6: Fix alleged compiler warning in ipv6_exthdrs_len()
Date: Mon, 16 Dec 2013 10:30:26 +0800
Message-ID: <CAPshTCjv44ypAjrv+0jJx08feBC-JsKaQAuLGD7SHNTssP1wEA@mail.gmail.com>
References: <1387127947-2075-1-git-send-email-hkchu@google.com>
	<20131215.203158.557626779911420893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:54579 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab3LPCa2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 21:30:28 -0500
Received: by mail-qc0-f178.google.com with SMTP id i17so3250819qcy.23
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 18:30:26 -0800 (PST)
In-Reply-To: <20131215.203158.557626779911420893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 9:31 AM, David Miller <davem@davemloft.net> wro=
te:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Sun, 15 Dec 2013 09:19:07 -0800
>
>> From: Jerry Chu <hkchu@google.com>
>>
>> It was reported that Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
>> ("net-gro: Prepare GRO stack for the upcoming tunneling support")
>> triggered a compiler warning in ipv6_exthdrs_len():
>>
>> net/ipv6/ip6_offload.c: In function =91ipv6_gro_complete=92:
>> net/ipv6/ip6_offload.c:178:24: warning: =91optlen=92 may be used uni=
nitialized in this function [-Wmaybe-u
>>     opth =3D (void *)opth + optlen;
>>                       ^
>>     net/ipv6/ip6_offload.c:164:22: note: =91optlen=92 was declared h=
ere
>>     int len =3D 0, proto, optlen;
>>                         ^
>> Note that there was no real bug here - optlen was never uninitialize=
d
>> before use. (Was the version of gcc I used smarter to not complain?)
>>
>> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>
> What is this patch against?
>
> It gets rejects when I try to apply it both with Hannes's patch rever=
ted
> and without it reverted.

It was against net-next of a few days old (and w/o Hannes's patch):

commit 68536053600425c24aba031c45f053d447eedd9c (netnext/master)
Author: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date:   Thu Dec 12 17:07:58 2013 +0100

    ipv6: fix incorrect type in declaration

I just did a git pull and will submit one against the latest net-next.
(I did not see any conflict though. Not sure why you can't apply the pa=
tch.)

Jerry
