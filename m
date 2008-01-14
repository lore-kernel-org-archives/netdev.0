From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in	2.6.24-rc6,	comparing
 with 2.6.22
Date: Mon, 14 Jan 2008 09:46:08 -0800
Message-ID: <478B9FE0.3040801@hp.com>
References: <1199871330.3298.132.camel@ymzhang>	<1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com> <1200280292.3151.24.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:9973 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbYANRqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 12:46:10 -0500
In-Reply-To: <1200280292.3151.24.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>*) netperf/netserver support CPU affinity within themselves with the 
>>global -T option to netperf.  Is the result with taskset much different? 
>>   The equivalent to the above would be to run netperf with:
>>
>>./netperf -T 0,7 ..
> 
> I checked the source codes and didn't find this option.
> I use netperf V2.3 (I found the number in the makefile).

Indeed, that version pre-dates the -T option.  If you weren't already 
chasing a regression I'd suggest an upgrade to 2.4.mumble.  Once you are 
at a point where changing another variable won't muddle things you may 
want to consider upgrading.

happy benchmarking,

rick jones
