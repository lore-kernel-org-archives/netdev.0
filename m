From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Tue, 15 Nov 2011 09:22:47 -0800
Message-ID: <4EC29FE7.70904@hp.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com> <4EC160B4.2040709@hp.com> <20111115015616.GA25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:36174 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836Ab1KORWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 12:22:50 -0500
In-Reply-To: <20111115015616.GA25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On most modern systems I suspect there will be little to no difference
> between bonding RX peformance and team performance.
>
> If there is any now, I suspect team and bond performance to be similar
> by the time team has to account for the corner-cases bonding has already
> resolved.  :-)
>
> Benchmarks may prove otherwise, but I've yet to see Jiri produce
> anything.  My initial testing doesn't demonstrate any measureable
> differences with 1Gbps interfaces on a multi-core, multi-socket system.

I wouldn't expect much difference in terms of bandwidth, I was thinking 
the demonstration would be made in the area of service demand (CPU 
consumed per unit work) and perhaps aggregate packets per second.

happy benchmarking,

rick jones
