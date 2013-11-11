From: Dave Taht <dave.taht@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 10:31:23 -0800
Message-ID: <CAA93jw7ciONyyUKNei5COVTA51tFWVBD4LQMp60wwxGGD=VBEQ@mail.gmail.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<21121.575.539384.948990@gargle.gargle.HOWL>
	<52810800.9020402@openwrt.org>
	<1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Felix Fietkau <nbd@openwrt.org>,
	Sujith Manoharan <sujith@msujith.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Avery Pennarun <apenwarr@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37620 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182Ab3KKSbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:31:24 -0500
Received: by mail-wi0-f174.google.com with SMTP id cb5so2582344wib.7
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 10:31:23 -0800 (PST)
In-Reply-To: <CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ah, this thread started with a huge regression in ath10k performance
with the new TSQ stuff, and isn't actually about a two line fix to the
mv ethernet driver.

http://comments.gmane.org/gmane.linux.network/290269

I suddenly care a lot more. And I'll care a lot, lot, lot more, if
someone can post a rrul test for before and after the new fq scheduler
and tsq change on this driver on this hardware... What, if anything,
in terms of improvements or regressions, happened to multi-stream
throughput and latency?

https://github.com/tohojo/netperf-wrapper
