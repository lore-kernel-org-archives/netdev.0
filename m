From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] sch_red: fix red_calc_qavg_from_idle_time
Date: Wed, 30 Nov 2011 23:44:46 +0100
Message-ID: <1322693086.2602.28.camel@edumazet-laptop>
References: <1322688891.2602.15.camel@edumazet-laptop>
	 <1322689213.2602.18.camel@edumazet-laptop>
	 <1322691053.2602.24.camel@edumazet-laptop>
	 <CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48737 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab1K3Wow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:44:52 -0500
Received: by eeaq14 with SMTP id q14so16574eea.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 14:44:51 -0800 (PST)
In-Reply-To: <CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 23:35 +0100, Dave Taht a =C3=A9crit=
 :

> One of my other problems is when I try to size red (or choke) appropr=
iately
> (or so I think) for GigE bandwidths and queue depths, it would fail
> to calculate the ewma value.

Do you have one example of such failure ?
