From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] bpf: Add verifier test case for alignment.
Date: Thu, 11 May 2017 10:55:07 -0400 (EDT)
Message-ID: <20170511.105507.1298287325238505877.davem@davemloft.net>
References: <20170510.151005.805363538289965960.davem@davemloft.net>
        <5914609A.9040709@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932514AbdEKOzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 10:55:14 -0400
In-Reply-To: <5914609A.9040709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 11 May 2017 15:01:14 +0200

> On 05/10/2017 09:10 PM, David Miller wrote:
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Thanks for all the tests! Did you check whether it also allows
> to lift some of the F_NEEDS_EFFICIENT_UNALIGNED_ACCESS flagged
> tests in test_verifier? I think we should now be able to rework
> that a bit, but not subject to this patch set, of course.

I'll have to take a look at that and test it out on Sparc.
