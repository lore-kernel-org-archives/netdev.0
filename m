From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate   estimators
Date: Thu, 01 Oct 2009 23:21:01 +0200
Message-ID: <4AC51D3D.8010700@gmail.com>
References: <4AC4FE07.5070204@gmail.com>	<20091001.123725.02194664.davem@davemloft.net>	<4AC519B1.1090701@gmail.com> <20091001.141406.62574384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:17260 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbZJAVWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:22:05 -0400
Received: by fg-out-1718.google.com with SMTP id 22so229024fge.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2009 14:22:08 -0700 (PDT)
In-Reply-To: <20091001.141406.62574384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 10/01/2009 11:14 PM:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 01 Oct 2009 23:05:53 +0200
> 
>> Since you ask... I wonder about this whole int plus quite a bit of
>> struct unreadability for one flag only. Maybe it could be queried
>> on qdisc level (with a flag if necessary), and additional parameter
>> of gnet_stats_copy_rate_est()? (Qdiscs should have no problem with
>> setting this param for their classes too.)
> 
> Certainly, that's another approach to this problem.
> 
> But logically, just like we wouldn't emit a block of RED scheduler
> data to 'tc' unless RED is actually configured, it seems consistent to
> not emit estimator data when no estimator is even there.

Sure! I've exaggerated with this additional parameter. ;-)

Jarek P.
