From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 10:11:02 +0100
Message-ID: <CAHXqBFKwkmBcsrJFy+0=h8cLxpzZgUo9fgvZuNo-DkAsw_kXqQ@mail.gmail.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
 <20120127205903.GG24507@electric-eye.fr.zoreil.com> <CAHXqBF+5WxSzGhrTLMEG1NXcULdnwWDHS8koTr907qRT9H5U8A@mail.gmail.com>
 <20120128083943.GA31278@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44615 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953Ab2A1JLW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 04:11:22 -0500
Received: by iacb35 with SMTP id b35so3013125iac.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 01:11:22 -0800 (PST)
In-Reply-To: <20120128083943.GA31278@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 28 stycznia 2012 09:39 u=BFytkownik Francois Romieu
<romieu@fr.zoreil.com> napisa=B3:
> Micha=B3 Miros=B3aw <mirqus@gmail.com> :
> [...]
>> You could pull the "enabled" flag into "flags".
>
> That's what I did first. Than I realized that they operate in differe=
nt
> locking context and I could remove some abstraction code I was not
> satisfied with. It will save me some time if you are sure about it an=
d
> can send a patch.

Hmm. Your locking in this patch seems suspicious. I'll reply to the
original with more comments.

Best Regards,
Micha=B3 Miros=B3aw
