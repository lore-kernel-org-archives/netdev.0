From: "Tom Herbert" <therbert@google.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Tue, 11 Mar 2008 16:48:26 -0700
Message-ID: <65634d660803111648l15c4d653t52b4fc9e8dfa531d@mail.gmail.com>
References: <20080305205116.5989A412541@localhost>
	 <20080305.132112.01598419.davem@davemloft.net>
	 <47D19147.9070609@qualcomm.com>
	 <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com>
	 <65634d660803110920g5103dc60ya055a10f999b4e25@mail.gmail.com>
	 <20080311165253.GG26963@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Max Krasnyanskiy" <maxk@qualcomm.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Steven Rostedt" <rostedt@goodmis.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:56664 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbYCKXsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 19:48:33 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m2BNmRxX021714
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 23:48:28 GMT
Received: from rv-out-0910.google.com (rvfc24.prod.google.com [10.140.180.24])
	by zps18.corp.google.com with ESMTP id m2BNmQc5027332
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 16:48:27 -0700
Received: by rv-out-0910.google.com with SMTP id c24so1679965rvf.13
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 16:48:26 -0700 (PDT)
In-Reply-To: <20080311165253.GG26963@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  Recent versions of Windows that are aware of RSS will instruct network
>  drivers to update their RSS indirection tables so that received
>  packets are handled on the same CPU as the thread likely to use the
>  received data.  This requires that the network stack knows the hash
>  function, so Microsoft specified a "Toeplitz hash" for IPv4 and IPv6.
>  You can expect that most hardware RSS implementations will use this
>  function and not a simple XOR.
>

Thanks.  I am planning to do the Toeplitz hash in the softRSS.  Also,
I was planning to add support for devices that provide the Toeplitz
hash but don't do full RSS.

One nice feature about Microsoft RSS seems to be the ability for the
stack to dynamically re-balance networking load of a device using
an indirection table that is set up in the device.  I was wondering if
this is supported in Linux stack or if anyone is working on that?

Tom
