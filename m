From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 4 Jan 2016 15:34:34 -0800
Message-ID: <CALx6S370tAh1g5q9trDuFxc84qOozT6XjdSKB94dvGRTUikfvA@mail.gmail.com>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
	<1451946988.8255.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35831 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbcADXef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:34:35 -0500
Received: by mail-ig0-f176.google.com with SMTP id to4so2870432igc.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 15:34:34 -0800 (PST)
In-Reply-To: <1451946988.8255.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 2:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-01-03 at 15:22 -0800, Tom Herbert wrote:
> \...
>> +402: /* Length 2, align is 1, 3, or 5 */
>> +     movb    (%rdi), %al
>> +     movb    1(%rdi), %ah
>
> Looks like a movw (%rdi),%ax
>
Wouldn't that be an unaligned access?

>
> Also you probably should send this patch to x86 maintainers.
>
>
