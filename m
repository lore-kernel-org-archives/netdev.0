From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATC] sctp: various fixes
Date: Mon, 21 Jul 2008 11:19:34 -0400
Message-ID: <4884A906.1000602@hp.com>
References: <20080718.230833.22196996.davem@davemloft.net>	<20080719.224047.228019059.davem@davemloft.net>	<48848B35.6050702@hp.com> <20080721.080535.194149976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:42800 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbYGUPTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:19:37 -0400
In-Reply-To: <20080721.080535.194149976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 21 Jul 2008 09:12:21 -0400
> 
>> David Miller wrote:
>>> From: David Miller <davem@davemloft.net>
>>> Date: Fri, 18 Jul 2008 23:08:33 -0700 (PDT)
>>>
>>>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>>>> Date: Sat, 19 Jul 2008 00:26:45 -0400
>>>>
>>>>> This is a bunch of SCTP fixes that have accumlated over the past week or
>>>>> so. 
>>>> All applied, thanks Vlad.
>>> Vlad, I had to add the following fix to the tree in order
>>> to unbreak the build when CONFIG_HIGHMEM is enabled.
>>>
>> ahh...  since tcp isn't a module, it didn't trigger that.
>>
>> Thanks Dave.  I didn't think about turning highmem off..
> 
> No problem, but the problematic case was turning highmem on :-)
> 

argh.....

CONFIG_HIGHMEM=y
...
CONFIG_SCTP=y

Ran my tests in kvm and it's easier to build stuff in.

-vlad
