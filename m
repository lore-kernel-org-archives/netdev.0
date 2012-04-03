From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 19:39:58 -0700
Message-ID: <4F7A62FE.2050103@hp.com>
References: <1333417997.18626.1.camel@edumazet-glaptop> <20120402.215911.1929019308299701014.davem@davemloft.net> <1333419304.18626.5.camel@edumazet-glaptop> <20120402.222300.1137842205135530387.davem@davemloft.net> <4F7A60A4.5040600@hp.com> <1333420452.18626.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, remi@remlab.net,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:21116 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab2DCCkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 22:40:00 -0400
In-Reply-To: <1333420452.18626.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2012 07:34 PM, Eric Dumazet wrote:
> On Mon, 2012-04-02 at 19:29 -0700, Rick Jones wrote:
>> I don't know it isn't entirely bitrotted, but there are streaming and
>> datagram AF_UNIX tests in netperf - they require conditional inclusion
>> via ./configure --enable-unixdomain:
>>
>> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#DG_005fSTREAM
>>
>
> Ah yes of course, I'll try that.
>
> BTW, do you have plans to support vmsplice()/splice() as a way to
> provide 0-copy to TCP_STREAM ?

I'd probably plead "too platform specific" but I've already got some 
platform-specific stuff in there like TCP_INFO so I probably cannot hide 
behind that.  Particularly if I ever do make "native" WSA calls for 
Windows...

Until now I'd not thought of vmsplice/splice though - only sendfile for 
zero copy, which should be there for TCP in the form of the TCP_SENDFILE 
test (unmigrated, so none of the omni output selection is available)

> I ask this because I am currently working on fixing splice(pipe ->
> socket) performance problem and need a standard benchmark to publish
> performance results.

I'll start to ponder, without promises.

rick
