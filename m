From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Tue, 26 Oct 2010 08:32:59 -0700
Message-ID: <AANLkTimMrqhWbnLXk1xbYPY7WT7Gazn5G=S1QvVkZ86Y@mail.gmail.com>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
	<201010260818.47523.helmut.schaa@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:8071 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231Ab0JZPdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 11:33:04 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o9QFX18g000312
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 08:33:02 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by kpbe15.cbf.corp.google.com with ESMTP id o9QFWvLV003664
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 08:33:00 -0700
Received: by pxi12 with SMTP id 12so1003156pxi.10
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 08:32:59 -0700 (PDT)
In-Reply-To: <201010260818.47523.helmut.schaa@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Wouldn't that break mac80211 QoS again for bridged AP mode interfaces (see
> commit deabc772f39405054a438d711f408d2d94d26d96, "net: fix tx queue selection
> for bridged devices implementing select_queue")?
>
Yes, looks like that would break.  I'll fix that.

If a device only has one real TX queue should we still call
ndo_select_queue, or can we bypass it? (to save one conditional)

Thanks,
Tom
