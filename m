From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 16:58:21 +0100
Message-ID: <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
References: <igorm@etf.rs>
	<1324049163-11207-1-git-send-email-igorm@etf.rs>
	<1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:52883 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759627Ab1LPP6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:58:25 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 40B0860160
	for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 16:58:24 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id NqukN5qtGelG for <netdev@vger.kernel.org>;
	Fri, 16 Dec 2011 16:58:23 +0100 (CET)
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 55E7F6015F
	for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 16:58:23 +0100 (CET)
Received: by ggdk6 with SMTP id k6so2837306ggd.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 07:58:21 -0800 (PST)
In-Reply-To: <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 1) Why is it needed ? Any RFC requires this bloat ?
>

RFC4293 defines ipIfStatsTable.
Also I did it because ipv6 has per interface stats.

> 2) Every patch in a patch serie must be compilable. Think about
> bisection. This is mandatory.
>

OK, I didn't know about that...
Do I need to resubmit it? If I do, I'l do that in monday.
Would it be acceptable to send it as one big patch?
BR
Igor
