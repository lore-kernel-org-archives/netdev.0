From: Gabriel Beddingfield <gabrbedd@gmail.com>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 13:05:16 -0500
Message-ID: <CAPbw_hy7xjhWSsiHnB9HN+ROCEUNzOS8aPsFwjvdY4FY+pRVjw@mail.gmail.com>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
	<1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAEnQRZAB=tKwr0wX2OrpG8iq5VaJPmssHEfC3U62bz1XL_2FHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63093 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435Ab1HVSFR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 14:05:17 -0400
Received: by ywf7 with SMTP id 7so3695352ywf.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 11:05:17 -0700 (PDT)
In-Reply-To: <CAEnQRZAB=tKwr0wX2OrpG8iq5VaJPmssHEfC3U62bz1XL_2FHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2011 at 12:19 PM, Daniel Baluta <daniel.baluta@gmail.co=
m> wrote:
>>> It appears to me that the ACK is off-by-one (should have been 27676=
).
>>> The server replies again with retransmissions. =A0This is with seve=
ral
>>> kernel versions on local machines, ranging from 2.6.31 to 2.6.38.
>
>> Not a bug if frame carried a FIN

The server packet had the FIN bit set.

> Well then, why do retransmissions occur?
> Gabriel could you post the full capture file?

Sure: http://gabe.is-a-geek.org/tmp/20110822-skyward-conversation-segme=
nt.tcpdump

I clipped the conversation to the vicinity of the problem.

-gabriel
