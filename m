From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10%
	regression	in	2.6.24-rc6,	comparing with 2.6.22
Date: Wed, 23 Jan 2008 08:42:24 +0800
Message-ID: <1201048944.3151.263.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>
	 <1200280292.3151.24.camel@ymzhang>  <478B9FE0.3040801@hp.com>
	 <1200979482.3151.103.camel@ymzhang> <1200982039.3151.120.camel@ymzhang>
	 <479637B1.5000706@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:56782 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752392AbYAWAoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 19:44:00 -0500
In-Reply-To: <479637B1.5000706@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-01-22 at 10:36 -0800, Rick Jones wrote:
> When parsing the -P option in scan_socket_args() of src/nettest_bsd.c, 
> netperf is using "break_args()" from src/netsh.c which indeed if the 
> command line says "-P 12345" will set both the local and remote port 
> numbers to 12345.  If instead you were to say "-P 12345,"  it will use 
> 12345 only for the netperf side.  If you say "-P ,12345" it will use 
> 12345 only for the netserver side.  To set both sides at once to 
> different values it would be "-P 12345,54321"
> 
> In theory, send_udp_rr() in src/nettest_bsd.c (or I suppose 
> scan_socket_args() could have more code added to it to check for a UDP 
> test over loopback, but probably needs to be a check for any local IP, 
> and unless this becomes something bigger than "Doctor! Doctor! It hurts 
> when I do this!" :) I'm inclined to leave it as caveat benchmarker and 
> perhaps some additional text in the manual.
I will instrument kernel to see if kernel does work like it is expected.

When an issue is found, we shouldn't escape by saying it's nothing to do
with me.

-yanmin


