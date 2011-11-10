From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] [RFC] net-netlink: fix tos/tclass for dual-stack ipv6 sockets
Date: Wed, 9 Nov 2011 17:52:07 -0800
Message-ID: <CAHo-Ooz0F2wmkXR_ShoA+R3eDbZwkf9ZwaysUAhrEDDfG-KoEA@mail.gmail.com>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
	<1320716800-9151-1-git-send-email-zenczykowski@gmail.com>
	<20111109.153530.2283817573824031015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53160 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943Ab1KJB7M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 20:59:12 -0500
Received: by qyk27 with SMTP id 27so5380343qyk.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 17:59:11 -0800 (PST)
In-Reply-To: <20111109.153530.2283817573824031015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/9 David Miller <davem@davemloft.net>:
> From: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Date: Mon, =C2=A07 Nov 2011 17:46:40 -0800
>
>> From: Maciej =C5=BBenczykowski <maze@google.com>
>>
>> Something along the following lines would be needed.
>>
>> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>
> This is terrible, see my other email, inet->tos doesn't matter even
> for mapped ipv6 sockets.

Oh, yes, I definitely agree that this is terrible.
Can we just get rid of tclass and use inet->tos for ipv6 as well?
