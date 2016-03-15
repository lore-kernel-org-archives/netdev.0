From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] SOCK_SEQPACKET socketpair must get SIGPIPE in AF_UNIX if
 one end is closed
Date: Tue, 15 Mar 2016 10:08:58 +0100
Message-ID: <CAG_fn=UEU+CyCs-=PoujgcYwp6Oq4dkbVGqSi+4VEdOEkqEMxw@mail.gmail.com>
References: <1457532623-125301-1-git-send-email-glider@google.com>
	<20160314.151923.1878027262976947807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	rweikusat@mobileactivedefense.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38798 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934395AbcCOJJA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 05:09:00 -0400
Received: by mail-wm0-f46.google.com with SMTP id l68so16303980wml.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:08:59 -0700 (PDT)
In-Reply-To: <20160314.151923.1878027262976947807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Done, thanks for your response!

On Mon, Mar 14, 2016 at 8:19 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Alexander Potapenko <glider@google.com>
> Date: Wed,  9 Mar 2016 15:10:23 +0100
>
>> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
>> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if th=
e
>> socket is no longer connected.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>
> Please format your Subject line properly, the format is:
>
>         [PATCH] $SUBSYSTEM: $DESCRIPTION.
>
> In this case "af_unx: " would be a proper subsystem marker.
>
> Also,
>
>> ---
>> I used the following program to check the kernel behavior:
>
> Please include this in your commit message rather than cutting it out
> using the "---" marker, as it will help people in the future
> understand your change and how you tested it.  More information is
> always better than less information.
>
> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicl=
e
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
