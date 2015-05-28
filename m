From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 10:49:47 -0700
Message-ID: <1432835387.7456.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <5567382E.4010706@gmail.com>
	 <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <133859123.129202.1432830817627.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <1432833476.7456.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2104973120.133348.1432834303388.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33316 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193AbbE1Rtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 13:49:50 -0400
Received: by igbpi8 with SMTP id pi8so120277898igb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 10:49:49 -0700 (PDT)
In-Reply-To: <2104973120.133348.1432834303388.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 13:31 -0400, jsullivan@opensourcedevel.com wrote:

> The overall product does but the video source feeds come over a different
> network via UDP. There are, however, RTMP quality control feeds coming across
> this connection.  There may also occasionally be test UDP source feeds on this
> connection but those are not production.  Thanks - John

This is important to know, because UDP wont benefit from GRO.

I was assuming your receiver had to handle ~88000 packets per second,
so I was doubting it could saturate one core,
but maybe your target is very different.
