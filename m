From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Tue, 6 Dec 2011 10:15:40 +0100
Message-ID: <CAFdo_mUkQNHNeftAUgjtr5XcFYLOJ6mcfejmWkbdMYYA=_Dkdg@mail.gmail.com>
References: <igorm@etf.rs>
	<1323162824-3196-1-git-send-email-igorm@etf.rs>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, davem@davemloft.net,
	Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:54541 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932851Ab1LFJPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 04:15:45 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id F176E60150
	for <netdev@vger.kernel.org>; Tue,  6 Dec 2011 10:15:44 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id Y6YZlowgqXvh for <netdev@vger.kernel.org>;
	Tue,  6 Dec 2011 10:15:43 +0100 (CET)
Received: from mail-pz0-f46.google.com (mail-pz0-f46.google.com [209.85.210.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id AEBAB60151
	for <netdev@vger.kernel.org>; Tue,  6 Dec 2011 10:15:42 +0100 (CET)
Received: by dadv6 with SMTP id v6so4991318dad.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 01:15:40 -0800 (PST)
In-Reply-To: <1323162824-3196-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm resubmiting this patch, because Francois have fixed Rx FIFO
overflowing and  Rx index race between FIFO overflow recovery and NAPI
handler.
BR
Igor
