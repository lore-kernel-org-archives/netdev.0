From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can I limit the number of active tx per TCP socket?
Date: Thu, 06 Mar 2014 06:52:37 -0800
Message-ID: <1394117557.27473.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	 <1394116691.27473.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:43919 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaCFOwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 09:52:39 -0500
Received: by mail-pa0-f53.google.com with SMTP id ld10so2729966pab.40
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 06:52:38 -0800 (PST)
In-Reply-To: <1394116691.27473.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-06 at 06:38 -0800, Eric Dumazet wrote:

> This is the intent of TCP small queue, but it was somehow broken by
> latest patch.
> 
> Also try FQ pacing
> 
> tc qdisc replace dev eth0 root fq

BTW, once you have FQ packet scheduler in place, you also can
use SO_MAX_PACING_RATE socket option on your flow if you know what is
the optimal throughput for your ppc receiver.
