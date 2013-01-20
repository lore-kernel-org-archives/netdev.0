From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix incorrect LOCKDROPPEDICMPS counter
Date: Sat, 19 Jan 2013 23:19:14 -0500
Message-ID: <CADVnQynpupJ3HTmSP3dxEE6MGi0bpq=B_WQMqdxnmxNSQLq3OA@mail.gmail.com>
References: <1358647837.3464.1050.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:54500 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab3ATETQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 23:19:16 -0500
Received: by mail-ea0-f172.google.com with SMTP id f13so2047377eaa.31
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2013 20:19:15 -0800 (PST)
In-Reply-To: <1358647837.3464.1050.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 19, 2013 at 9:10 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit 563d34d057 (tcp: dont drop MTU reduction indications)
> added an error leading to incorrect accounting of
> LINUX_MIB_LOCKDROPPEDICMPS
>
> If socket is owned by the user, we want to increment
> this SNMP counter, unless the message is a
> (ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED) one.
>
> Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
