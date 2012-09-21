From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: HTB vs CoDel performance
Date: Fri, 21 Sep 2012 15:23:33 +0800
Message-ID: <CAF1ivSYBci4VCL8CgV5TQBrvOD9eeW8-xXVq2DWfOrcmJxxMLg@mail.gmail.com>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
	<1347961511.26523.216.camel@edumazet-glaptop>
	<CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com>
	<1347963353.26523.224.camel@edumazet-glaptop>
	<CAF1ivSYQiXBOtzZdDUKEqWWsW5cgLgSkLs88Dvkppb02yN6wTg@mail.gmail.com>
	<5059FA30.8070209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	networking <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:58583 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab2IUHYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 03:24:16 -0400
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 2E1C4DBC0C
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 15:23:36 +0800 (CST)
Received: by lbbgj3 with SMTP id gj3so3471083lbb.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 00:23:33 -0700 (PDT)
In-Reply-To: <5059FA30.8070209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 1:00 AM, Rick Jones <rick.jones2@hp.com> wrote:
> On 09/18/2012 06:26 PM, Lin Ming wrote:
>>
>> On Tue, Sep 18, 2012 at 6:15 PM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>>
>>> Are you really cpu limited ? You might hit some clocks artifacts.
>>
>>
>> Did you mean the cpu speed? It's an ARMv5 processor.
>> BogoMIPS        : 1196.03
>
>
> At the risk of typing into Eric's keyboard, he was asking if you were
> saturating the CPU - was it getting to 100% utilization, that sort of thing.

Yes, ~98% utilization.

>
>
>>> rate limiting to 1Gbps probably need high resolution timers.
>>
>>
>> High resolution timer is enabled.
>
>
> When you are running your tests, what sort of CPU utilization do you see on
> the CPU of your router with HTB on vs off.  Some "quick and dirty" netperf

HTB off: ~85%
HTB on: ~98%

> tests on an Centrino-based laptop suggested that as an end system at least,
> HTB at 1 GbE (using your tc commands) increases service demand (what netperf
> calculates as CPU consumed per unit of work performed) ~15% for bulk
> transfer (netperf TCP_STREAM) and ~18% for small packet request/response
> (TCP_RR).
>
> rick jones
