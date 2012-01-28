From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 09:39:43 +0100
Message-ID: <20120128083943.GA31278@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com> <20120127205903.GG24507@electric-eye.fr.zoreil.com> <CAHXqBF+5WxSzGhrTLMEG1NXcULdnwWDHS8koTr907qRT9H5U8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32847 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953Ab2A1Iuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 03:50:44 -0500
Content-Disposition: inline
In-Reply-To: <CAHXqBF+5WxSzGhrTLMEG1NXcULdnwWDHS8koTr907qRT9H5U8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> :
[...]
> You could pull the "enabled" flag into "flags".

That's what I did first. Than I realized that they operate in different
locking context and I could remove some abstraction code I was not
satisfied with. It will save me some time if you are sure about it and
can send a patch.

--=20
Ueimor
