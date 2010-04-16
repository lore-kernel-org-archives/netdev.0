From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 13:42:57 -0700
Message-ID: <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
	 <1271443994.16881.4249.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:29241 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932379Ab0DPUnB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 16:43:01 -0400
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o3GKgxPs015188
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 22:42:59 +0200
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by kpbe13.cbf.corp.google.com with ESMTP id o3GKgvHF012031
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 15:42:58 -0500
Received: by pvb32 with SMTP id 32so1822983pvb.34
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 13:42:57 -0700 (PDT)
In-Reply-To: <1271443994.16881.4249.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 11:53 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 16 avril 2010 =E0 11:35 -0700, Tom Herbert a =E9crit :
>> Results with "tbench 16" on an 8 core Intel machine.
>>
>> No RPS/RFS: =A02155 MB/sec
>> RPS (0ff mask): 1700 MB/sec
>> RFS: 1097
>>

Blah, I mistakingly reported that... should have been:

No RPS/RFS:  2155 MB/sec
RPS (0ff mask): 1097 MB/sec
RFS: 1700 MB/sec

Sorry about that!

>> I am not particularly surprised by the results, using loopback
>> interface already provides good parallelism and RPS/RFS really would
>> only add overhead and more trips between CPUs (last part is why RPS =
<
>> RFS I suspect)-- I guess this is why we've never enabled RPS on
>> loopback :-)
>>
>> Eric, do you have a particular concern that this could affect a real=
 workload?
>>
>
> I was expecting RFS to be better than RPS at least, for this particul=
ar
> workload (tcp over loopback)
>
This was my expectation too, and what my "corrected" numbers show :-)
But, I take it this is different in your results?

Tom
