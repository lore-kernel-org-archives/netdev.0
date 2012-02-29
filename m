From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 29 Feb 2012 05:00:25 +0400
Message-ID: <4F4D78A9.2090802@msgid.tls.msk.ru>
References: <4F3BABD3.5070404@msgid.tls.msk.ru> <1329311013.2437.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F4CBCBC.8000703@msgid.tls.msk.ru> <20120228.140740.2121187297378484175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:50499 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab2B2Ip1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 03:45:27 -0500
In-Reply-To: <20120228.140740.2121187297378484175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.02.2012 23:07, David Miller wrote:
[]
>>> If you believe a fix is needed, just shout :)
>>
>> I think the a fix is needed.  I still don't understand where our
>> unexpected redirects are coming from, but we had two more occurences
>> of this very issue.  After applying the two patches:
>>
>> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae route: fix ICMP redirect validation
>> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc ipv4: fix redirect handling
> 
> If you were paying attention, you'd see that both of these patches are
> in Greg's stable queue already.

Indeed, they're in current 3.0.23 review cycle -- somehow
I haven't noticed.  This should be ok, thank you!

/mjt
