From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 2 Dec 2011 22:54:50 +0100
Message-ID: <CAFdo_mUZembr4MEGUt9efNtfnuCs4ddHUCDjLE64WnWwytTpzw@mail.gmail.com>
References: <igorm@etf.rs>
	<1322831399-23505-1-git-send-email-igorm@etf.rs>
	<1322836191.2762.3.camel@edumazet-laptop>
	<CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
	<1322838687.2762.18.camel@edumazet-laptop>
	<6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
	<1322844451.2762.36.camel@edumazet-laptop>
	<CAFdo_mWtxexXXCpFZsQKAJ96ZXEnDRiBsb4zFO8oR0hc6gXPMQ@mail.gmail.com>
	<1322845932.2762.38.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:52631 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755778Ab1LBV5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 16:57:39 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id C102360159
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 22:57:36 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id 0CbGSeoo5kii for <netdev@vger.kernel.org>;
	Fri,  2 Dec 2011 22:57:36 +0100 (CET)
Received: from mail-pz0-f46.google.com (mail-pz0-f46.google.com [209.85.210.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 9CD1F12015C
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 22:54:53 +0100 (CET)
Received: by dadv6 with SMTP id v6so1836597dad.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 13:54:50 -0800 (PST)
In-Reply-To: <1322845932.2762.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Reread what I said : "BQL must be lightweight"
>
> Not : "No lock should be used"
>
> OK ?
>

I'm out of ideas.

Do you think, if I remove netdev_reset_queue(tp->dev); from
rtl8169_init_ring_indexes,
and spin_locks, of course, that would be a good solution.

As far as I could see in marvell/sky2.c,  sfc/tx.c and intel/e1000e/netdev.c
netdev_completed is called with out any lock.
Please correct me if I'm wrong.
BR
Igor
