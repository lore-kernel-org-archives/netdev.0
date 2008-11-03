From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Mon, 03 Nov 2008 12:20:25 +0100
Message-ID: <490EDE79.6070500@trash.net>
References: <20081031132010.GA18895@ff.dom.local> <20081102.003700.198708146.davem@davemloft.net> <20081103082926.GA4698@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39954 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105AbYKCLUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 06:20:32 -0500
In-Reply-To: <20081103082926.GA4698@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Sun, Nov 02, 2008 at 12:37:00AM -0700, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Fri, 31 Oct 2008 13:20:10 +0000
>>
>> Jarek, I applied this patch and your second one to net-next-2.6
>>
>> But I did this only because I trust that you will address Stephen's
>> feedback wrt. making existing netem functionality available in
>> some way.
>>
>> Otherwise I'll have to revert these changes.
> 
> Hmm... I thought there was kind of RFC for this, and it looked like
> Patrick's idea won 100% of votes, but I'm not good in counting...
> 
> http://marc.info/?l=linux-netdev&m=122469801712438&w=2
> http://marc.info/?l=linux-netdev&m=122469674709761&w=2
> 
> Anyway, IMHO adding TBF etc. functionalities to tfifo doesn't make
> much sense, and if they are really needed it's better to revert
> these patches and chose one of the other ways of doing reorder
> proposed in this earlier thread.

Whats wrong with simply using TBF as parent qdisc of netem?
