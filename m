From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/20] Batch network namespace cleanup
Date: Mon, 30 Nov 2009 11:22:38 -0800
Message-ID: <m1y6ln4y2p.fsf@fess.ebiederm.org>
References: <m1ljhodbtw.fsf@fess.ebiederm.org> <1259585043.873.21.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34928 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbZK3TWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:22:37 -0500
In-Reply-To: <1259585043.873.21.camel@bigi> (jamal's message of "Mon\, 30 Nov 2009 07\:44\:03 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> On Sun, 2009-11-29 at 17:46 -0800, Eric W. Biederman wrote:
>> 
>> Recently Jamal and Daniel perform some experiments and found that
>> large numbers of network namespace exiting simultaneously is very
>> inefficient.  24+ minutes in some configurations.  The cpu overhead
>> was negligible but it results in long hold times of net_mutex, and
>> memory being consumed a long time after the last user has gone away.
>> 
>> I looked into it and discovered that by batching network namespace
>> cleanups I can reduce the time for 4k network namespaces exiting from
>> 5-7 minutes in my configuration to 44 seconds.
>
> Excellent work Eric. I have time today so i can test these patches
> status quo vs.
> This is against net-next?

Yes.

Eric
