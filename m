From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 06 Feb 2015 09:48:19 -0800
Message-ID: <54D4FE63.9020602@hp.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com> <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com> <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com> <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com> <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com> <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com> <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com> <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com> <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com> <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com> <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com> <1423230001.31870.128.camel@edumazet-glaptop2
 .roam.corp.google.com> <CA+BoTQnEvF_mi68gyFns67oKC=8jEYdi3tLuW5dNj20KwUNs9A@mail.gmail.com> <1423233346.31870.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hp.com ([15.217.128.52]:32888 "EHLO
	g2t2353.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbbBFRsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 12:48:22 -0500
In-Reply-To: <1423233346.31870.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you increase ability to flood on one flow, then you need to make sure
> receiver has big rcvbuf as well.
>
> echo 2000000 >/proc/sys/net/core/rmem_default
>
> Otherwise it might drop bursts.
>
> This is the kind of things that TCP does automatically, not UDP.

An alternative, if the application involved can make explicit 
setsockopt() calls to set SO_SNDBUF and/or SO_RCVBUF, is to tweak 
rmem_max and wmem_max and then let the application make the setsockopt() 
calls.

Which path one would take would depend on circumstances I suspect.

rick jones
