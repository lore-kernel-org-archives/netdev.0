From: ajay seshadri <seshajay@gmail.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 14:32:23 -0500
Message-ID: <CAGA2gK7tjQZ6sq1qqTua_J0uY47Dq7h-vWR=c_LQReq3Rwc=_Q@mail.gmail.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
	<CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
	<52A749CB.1010909@hp.com>
	<52A74E32.4040900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:50515 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3LJTcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:32:23 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so9406009iej.40
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 11:32:23 -0800 (PST)
In-Reply-To: <52A74E32.4040900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 12:24 PM, Rick Jones <rick.jones2@hp.com> wrote:
>> If you want to compare the "fundamental" path length difference between
>> IPv4 and IPv6, without any concerns about stateless offloads like CKO or
>> GRO et al, you could use something like a single-byte netperf TCP_RR test.
>>
>> netperf -c -C -H <remote> -t TCP_RR
>
> Or UDP_RR, since that is your usage case...

I am not sure what you mean by '"fundamental" path length difference',
can you please elaborate. For now i use:
./netperf -t UDP_STREAM -H <remote> -l 60 -- -m 1450
I am trying to find the maximum throughput I can get at 1500 MTU for
UDP packets (IPv4 / IPv6) without using offloading.
