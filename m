From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 08:09:46 -0700
Message-ID: <i2q65634d661004200809ydba56c35g785ba51900c379f7@mail.gmail.com>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
	 <1271750198.3845.216.camel@edumazet-laptop>
	 <4BCDA2B5.4060609@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25510 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab0DTPJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 11:09:50 -0400
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o3KF9mX8007793
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:09:48 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe13.cbf.corp.google.com with ESMTP id o3KF9lcm020207
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 10:09:47 -0500
Received: by pvg12 with SMTP id 12so3805909pvg.10
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:09:47 -0700 (PDT)
In-Reply-To: <4BCDA2B5.4060609@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I thought about this for some time...
>
> Do we really need the port numbers here at all? A simple
> addr1^addr2 can provide a good enough pointer for
> distribution amongst CPUs.
>

What about a server behind a TCP proxy?  Also, need to minimize
collisions for RPS to be effective.

Tom

> The real connection tracking is better done locally at the
> corresponding CPU. That way a potential cache miss can be
> avoided and the still needed hash calculation for
> connection tracking will be offloaded.
>
>
> Franco
>
>
