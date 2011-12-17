From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Sat, 17 Dec 2011 18:28:30 +0100
Message-ID: <CAFdo_mUcUXhZK20t92NJCetcPV=tst9EYTUhHdbhFU0=FjY2dA@mail.gmail.com>
References: <igorm@etf.rs>
	<1323694834-2844-1-git-send-email-igorm@etf.rs>
	<1324071003.2621.33.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:38006 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab1LQR2f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 12:28:35 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 7C4D5120132
	for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 18:28:33 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id Rvm0JwsaeOeD for <netdev@vger.kernel.org>;
	Sat, 17 Dec 2011 18:28:33 +0100 (CET)
Received: from mail-tul01m020-f174.google.com (mail-tul01m020-f174.google.com [209.85.214.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id A9BB7120133
	for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 18:28:32 +0100 (CET)
Received: by obcwo16 with SMTP id wo16so901212obc.19
        for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 09:28:30 -0800 (PST)
In-Reply-To: <1324071003.2621.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why here in rtl8169_xmit_frags() ?
>
> If done from rtl8169_start_xmit(), you already have "dev" pointer.
>
> =A0 =A0 =A0 =A0netdev_sent_queue(dev, skb->len);
>

I put it there because actual dma maping is occurring in that function.
Logically there is no difference if I put it after calling of function
rtl8169_xmit_frags() in rtl8169_start_xmit().

If You think it would be better to be in function rtl8169_start_xmit,
for performance reasons I'l put it there.

In any case I'l resubmit this patch in Monday. After all it's Saturday =
:)
BR
Igor
