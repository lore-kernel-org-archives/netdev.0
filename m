From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 12:18:36 -0700
Message-ID: <4906140C.5010004@hp.com>
References: <1224905848.5161.27.camel@marge.simson.net>	<20081024.221653.23695396.davem@davemloft.net>	<1224914333.3822.18.camel@marge.simson.net>	<20081025.001940.251852864.davem@davemloft.net>	<1224919985.5373.10.camel@marge.simson.net>  <4905F9BD.100@hp.com> <1225134690.4942.11.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:10236 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbYJ0TSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 15:18:41 -0400
In-Reply-To: <1225134690.4942.11.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>I cannot guarantee it will help, but the global -T option to pin netperf 
>>or netserver to a specific CPU might help cut-down the variables.
> 
> 
> Yup, and how.  Early on, the other variables drove me bat-shit frigging
> _nuts_.  I eventually selected a UP config to test _because_ those other
> variables combined with SMP overhead and config options drove crazy ;-) 
> 
> 
>>FWIW netperf top of trunk omni tests can now also determine and report 
>>the state of SELinux. 

http://www.netperf.org/svn/netperf2/trunk/src/netsec_linux.c

Pointers to programtatic detection of AppArmour and a couple salient 
details about firewall (enabled, perhaps number of rules) from any 
quarter would be welcome.

>> They also have code to accept or generate their 
>>own RFC4122-esque UUID.  Define some connical tests and then ever closer 
>>to just needing some database-fu and automagic testing I suppose... 
>>things I do not presently posess but am curious enough to follow some 
>>pointers.
> 
> 
> Hrm. I'm going to have to save that, and parse a few times. (usual)

Plot thickening, seems that autotest knows about some version of 
netperf2 already...  i'll be trying to see if there is some benefit to 
autotest to netperf2's top of trunk having the keyval output format, and 
if autotest groks paired systems to more easily do over a network testing.

>>happy benchmarking,
> 
> 
> Not really, but I can't seem to give up ;-)

then I guess I'll close with

successful benchmarking,

if not necessarily happy :)

rick jones
