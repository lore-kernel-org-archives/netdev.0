From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: kernel panic when using netns+bridges+tc(netem)
Date: Thu, 6 May 2010 13:23:16 +0200
Message-ID: <h2vb9800b71005060423rc0f4bd3g4109e90f798d5157@mail.gmail.com>
References: <o2wb9800b71005051801uc575c6abp5bad3bd50d54ef96@mail.gmail.com>
	 <1273128002.2304.4.camel@edumazet-laptop>
	 <1273128429.2304.5.camel@edumazet-laptop>
	 <1273129187.2304.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52418 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756294Ab0EFLXT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 07:23:19 -0400
Received: by vws12 with SMTP id 12so1848671vws.19
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 04:23:18 -0700 (PDT)
In-Reply-To: <1273129187.2304.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

On Thu, May 6, 2010 at 08:59, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
>> > Could you please try following patch ?
> David, this is a stable candidate, once tested and acked, thanks !
>
> [PATCH] veth: Dont kfree_skb() after dev_forward_skb()

I have been running a bunch of benchmarks and it didn't cause any
trouble. Seems the fix is good

Thanks a lot!!

--=20
Mart=EDn Ferrari
