From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 08:37:36 -0700
Message-ID: <49E8A240.8050404@us.ibm.com>
References: <alpine.DEB.1.10.0904161136220.15629@qirst.com> <20090416174422.GB28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161508520.15835@qirst.com> <20090416.151641.220683663.davem@davemloft.net> <alpine.DEB.1.10.0904170952050.11877@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	dlstevens@us.ibm.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:42627 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759025AbZDQPhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 11:37:40 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3HFa39V016085
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 09:36:03 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3HFbac5226924
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 09:37:36 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3HFbZ81005315
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 09:37:36 -0600
In-Reply-To: <alpine.DEB.1.10.0904170952050.11877@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> On Thu, 16 Apr 2009, David Miller wrote:
> 
>> No Christoph, do this right.
>>
> 	> Linux by default will behave the way it has for 15+ years.  And if an
>> application wants new behavior, you have to ask for it.
>>
>> End of story.
> 
> This is not right. All other OSes filter multicast traffic according to
> the multicast groups subscribed too (and that includes the evil one).
> There is no requirement of asking for "new" behavior. Why should multicast
> applications have to add special code to request something that comes by
> default on other platforms?

I need the current behaviour to not change, as it would
break some people I support.  DaveM is making the right
decision here, and I fully support this.

And I'm one of those people working on low latency and
hoping messaging clients get better in their multicast
usage..just that this is not one of those ways.

Ideally, you could tweak OS environment configuration
setting, if you don't want per socket. But it cannot
be the default.


thanks,
Nivedita

