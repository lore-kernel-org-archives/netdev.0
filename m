From: Rick Jones <rick.jones2@hp.com>
Subject: Re: First pass at MSG_FASTOPEN support in top-of-trunk netperf
Date: Tue, 28 Aug 2012 10:10:30 -0700
Message-ID: <503CFB86.2020008@hp.com>
References: <5020739A.3060809@hp.com> <CAFbMe2MY11VoXbGPDcLzHiHBzskoQk6eL1S9VWV5Vd1u0aRjNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:16388 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab2H1RKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 13:10:32 -0400
In-Reply-To: <CAFbMe2MY11VoXbGPDcLzHiHBzskoQk6eL1S9VWV5Vd1u0aRjNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> There was a ~25% increase in TCP_CRR performance, even without the server
>> actually accepting the magic TCP option.  Is that actually expected?
>
> I have a locally enhanced netperf for TCP_CRR over Fast Open and I've
>   noticed the numbers can change drastically between runs. I have not got
> the time to investigate why. (Does it have to do with scheduler and CPU
> locality?) How consistent is your perf number?

I recall the performance being reasonably consistent but there has been 
a vacation of my own in the middle there so my dimm memory is a bit fuzzy :)

Historically (and going beyond just Linux) a TCP_CRR test can have some 
non-trivial run to run variation thanks to (attempted) TIME_WAIT reuse. 
  Whether that is happening to you I don't know, but it might be worth a 
look.

> I plan to submit the server side code soon and will work with you to add
> the server side support to TCP_CRR (it requires a new TCP_FASTOPEN
> socket option to enable Fast Open on a listener.)

Works for me.

happy benchmarking,

rick jones
