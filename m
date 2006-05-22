From: "=?ISO-8859-1?Q?S=E9rgio_Gomes?=" <sergiomdgomes@gmail.com>
Subject: Re: Routing header reversal in Linux kernel
Date: Mon, 22 May 2006 15:43:32 +0000
Message-ID: <89fb8be00605220843u7c0869d6n4f9b004966db520@mail.gmail.com>
References: <89fb8be00605220642l3730a60alf7015ee626b8ed69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.205]:45899 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750704AbWEVPnd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 11:43:33 -0400
Received: by wx-out-0102.google.com with SMTP id s6so873395wxc
        for <netdev@vger.kernel.org>; Mon, 22 May 2006 08:43:32 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <89fb8be00605220642l3730a60alf7015ee626b8ed69@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, I've simplified the problem greatly, please ignore my previous post=
=2E

I am no longer using the backdoor and I am following the RFC by using
an authentication header between both machines.

This, in theory, should allow for routing header reversal, i.e., when
I send a packet from one machine with a routing header, the reply
should follow the same route, in the opposite direction. But alas, the
routing header is not being reversed in the 2nd machine, whether it be
on a listening or on an active socket.

I believe the implementation is therefore incorrect. However, I am by
no means an expert, and may be overlooking some detail, like a /proc
option or a later RFC that specifies the AH usage in more detail.
Would anyone care to comment on this?



On 5/22/06, S=E9rgio Gomes <sergiomdgomes@gmail.com> wrote:
> Greetings!
>
> I am a final year student in Instituto Superior T=E9cnico, Lisbon,
> Portugal, and part of my final project requires the use of IPv6
> routing headers.
>
> In particular, I need the route reversal to work. Now, as it didn't, =
I
> began analysing the source code, and found a comment, stating that it
> was a known problem with the IPv6 standard (as I was aware) and that =
a
> way had been built around it via a constant, to avoid the whole AH
> mess the RFC imposes.
>
> So I was hoping someone could help me with something. The problem is
> that even if I remove that verification, it does not work --
> specifically, it looks as though the kernel is prepared to reverse
> routing headers on a listening socket (i.e., a passive one), but not
> on an active
> socket (that is, one making the connection). My terminology is
> probably wrong, but I hope you got my point.
>
> However, I have only looked into this now, so I barely understand the
> IPv6 implementation in the Linux kernel. I was hoping that you would
> be able to shed some light into the subject, namely: is it at all
> possible to have a TCP socket initiate a connection, receive a SYN+AC=
K
> from the remote socket that includes a routing header, and reverse
> this header for the remaining packets in the TCP connection?
>
> Thanks!
>
> S=E9rgio Gomes
>
