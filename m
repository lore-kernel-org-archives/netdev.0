From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH V2] sch_red: fix red_calc_qavg_from_idle_time
Date: Wed, 30 Nov 2011 23:35:01 +0100
Message-ID: <CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
References: <1322688891.2602.15.camel@edumazet-laptop>
	<1322689213.2602.18.camel@edumazet-laptop>
	<1322691053.2602.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44625 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab1K3WfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:35:02 -0500
Received: by iage36 with SMTP id e36so1438663iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 14:35:01 -0800 (PST)
In-Reply-To: <1322691053.2602.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 11:10 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Since commit a4a710c4a7490587 (pkt_sched: Change PSCHED_SHIFT from 10=
 to
> 6) it seems RED/GRED are broken.

> red_calc_qavg_from_idle_time() computes a delay in us units, but this
> delay is now 16 times bigger than real delay, so the final qavg resul=
t
> smaller than expected.

I've been scratching my head about RED's behavior for a while.

Pre-BQL I was unable to even see red behave, so we're still ahead
on this game.

I will apply this patch to the ongoing work. Thank you.

http://www.bufferbloat.net/issues/312

One of my other problems is when I try to size red (or choke) appropria=
tely
(or so I think) for GigE bandwidths and queue depths, it would fail
to calculate the ewma value.


--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
