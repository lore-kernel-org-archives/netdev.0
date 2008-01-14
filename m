From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in
	2.6.24-rc6,	comparing with 2.6.22
Date: Mon, 14 Jan 2008 11:11:32 +0800
Message-ID: <1200280292.3151.24.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:60495 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751360AbYANDOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 22:14:45 -0500
In-Reply-To: <4787ADDA.7090602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-01-11 at 09:56 -0800, Rick Jones wrote:
> >>The test command is:
> >>#sudo taskset -c 7 ./netserver
> >>#sudo taskset -c 0 ./netperf -t TCP_RR -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -r 1,1
> 
> A couple of comments/questions on the command lines:
Thanks for your kind comments.

> 
> *) netperf/netserver support CPU affinity within themselves with the 
> global -T option to netperf.  Is the result with taskset much different? 
>    The equivalent to the above would be to run netperf with:
> 
> ./netperf -T 0,7 ..
I checked the source codes and didn't find this option.
I use netperf V2.3 (I found the number in the makefile).

> .
> 
> The one possibly salient difference between the two is that when done 
> within netperf, the initial process creation will take place wherever 
> the scheduler wants it.
> 
> *) The -i option to set the confidence iteration count will silently cap 
> the max at 30.
Indeed, you are right.

-yanmin


