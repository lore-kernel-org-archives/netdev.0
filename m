From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 11:01:28 -0700 (PDT)
Message-ID: <20170809.110128.709552645127117641.davem@davemloft.net>
References: <63b41a38e0d58536700c999ade7c2c267bd2613d.1502272924.git.daniel@iogearbox.net>
        <20170809.095553.268665355274669790.davem@davemloft.net>
        <598B3FCA.7060904@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbdHISB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:01:29 -0400
In-Reply-To: <598B3FCA.7060904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 09 Aug 2017 19:00:58 +0200

> On 08/09/2017 06:55 PM, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Wed,  9 Aug 2017 12:23:53 +0200
>>
>>>    [1] https://github.com/borkmann/llvm/tree/bpf-insns
>>
>> How is this "backwards compatible"?
>>
>> If someone takes a new LLVM and tries to load those programs
>> into an older kernel they will be rejected.
>>
>> There appears to be no effort to make things work cleanly in
>> that situation at all.
> 
> No, that was just the patch I used for LLVM to enable the
> insns, so not the final one that will be submitted there
> officially where we have a switch to enable/disable this
> functionality.

So how does this switch work and how are people expected to use this
switch?  What is the default value and is it ever expected to change
in the future?

Yeah this seems hella awesome to get cilium programs smaller and
faster in a restricted environment where you control the running
kernel and everything.

But from a review perspective one should be completely uninterested in
that.

So, generally speaking how does this all pan out?  I seriously doubt
the wisdom of this.  You'll have to convince me of the long term
viability and whether we ever get to the point where everyone can
benefit from this. :)
