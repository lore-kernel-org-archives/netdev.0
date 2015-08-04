From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 4 Aug 2015 15:25:28 -0700
Message-ID: <CALx6S37yEGoXeXTJfYSGDbmBHSwg8LqogRVK55my5Z46daxaCA@mail.gmail.com>
References: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
	<1722301438673827@web16h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Laing <richard.laing@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pch@ordbogen.com, "jmorris@namei.org" <jmorris@namei.org>
To: Oleg A Arkhangelsky <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34248 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbHDWZ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 18:25:29 -0400
Received: by ioea135 with SMTP id a135so31870960ioe.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 15:25:28 -0700 (PDT)
In-Reply-To: <1722301438673827@web16h.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2015 at 12:37 AM, Oleg A Arkhangelsky <sysoleg@yandex.ru=
> wrote:
>
>
> 04.08.2015, 04:29, "Richard Laing" <richard.laing@alliedtelesis.co.nz=
>:
>> Enable flow-based ECMP.
>
> Looks like your approach is only restricted to the case when sockets =
are
> involved. What about forwarded traffic (IP routing case)?
>
skb_get_hash_flowi4 can be called to get the hash now. This should
work with or without (connected) sockets.

Thanks,
Tom

> Have you seen similar work done by Peter N=C3=B8rlund?
>
> http://comments.gmane.org/gmane.linux.kernel.api/12201
>
> --
> wbr, Oleg.
>
> "Anarchy is about taking complete responsibility for yourself."
>       Alan Moore.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
