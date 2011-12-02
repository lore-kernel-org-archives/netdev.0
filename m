From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 2 Dec 2011 18:00:57 +0100
Message-ID: <CAFdo_mWtxexXXCpFZsQKAJ96ZXEnDRiBsb4zFO8oR0hc6gXPMQ@mail.gmail.com>
References: <igorm@etf.rs>
	<1322831399-23505-1-git-send-email-igorm@etf.rs>
	<1322836191.2762.3.camel@edumazet-laptop>
	<CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
	<1322838687.2762.18.camel@edumazet-laptop>
	<6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
	<1322844451.2762.36.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:44959 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807Ab1LBRBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 12:01:01 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 9EE8160146
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 18:01:00 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id UsHjDTmroAZM for <netdev@vger.kernel.org>;
	Fri,  2 Dec 2011 18:01:00 +0100 (CET)
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id C728412014E
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 18:00:59 +0100 (CET)
Received: by ggnr5 with SMTP id r5so3151937ggn.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 09:00:58 -0800 (PST)
In-Reply-To: <1322844451.2762.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> They are initted at device setup.
>

What about when device is reseted?

>
> Oh well, no, dont do that. BQL must be lightweight.
>

Forcedeth driver utilizes spin_locks. :)
