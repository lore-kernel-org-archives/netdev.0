From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 02/12] net: sched: free per cpu bstats
Date: Mon, 04 Jan 2016 10:08:05 -0800
Message-ID: <568AB505.9000508@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>	 <20151230175130.26257.98195.stgit@john-Precision-Tower-5810>	 <568A8DF5.7030505@iogearbox.net> <1451928758.8255.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, aduyck@mirantis.com, brouer@redhat.com,
	davem@davemloft.net, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36186 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbcADSIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 13:08:21 -0500
Received: by mail-pa0-f65.google.com with SMTP id a20so10338677pag.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 10:08:21 -0800 (PST)
In-Reply-To: <1451928758.8255.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-04 09:32 AM, Eric Dumazet wrote:
> On Mon, 2016-01-04 at 16:21 +0100, Daniel Borkmann wrote:
>> On 12/30/2015 06:51 PM, John Fastabend wrote:
>>> When a qdisc is using per cpu stats only the bstats are being
>>> freed. This also free's the qstats.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> Seems like a bug fix, current code seems to free this only in error
>> path in qdisc_create(). Should this go to -net as an individual one?
> 
> Absolutely, this is needed in -net as ingress qdisc uses this stuff
> already.
> 
> 

Yep, I'll push a patch for -net today.
