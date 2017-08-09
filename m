From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 23:29:55 +0200
Message-ID: <598B7ED3.5030005@iogearbox.net>
References: <598B3FCA.7060904@iogearbox.net>    <20170809.110128.709552645127117641.davem@davemloft.net>        <598B7162.90509@iogearbox.net> <20170809.142600.872268659837843440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52414 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdHIVaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 17:30:01 -0400
In-Reply-To: <20170809.142600.872268659837843440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2017 11:26 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Wed, 09 Aug 2017 22:32:34 +0200
>
>> For the case of cilium, we are not in control of the kernel, by
>> the way, we run a few probes that are small BPF insns snippets
>> that test the kernel for presence of certain features (e.g. helper,
>> verifier, maps) and enable/disable them accordingly later in the
>> code generation. On the user space side, we're indeed a bit more
>> flexible and have no such restriction.
>>
>> Plan is for LLVM as one of the frontends that generate byte code
>> (ply, for example, can probe the kernel directly for its code
>> generation) to have i) a target specific option to offer a
>> possibility to explicitly enable the extension by the user (as we
>> have with -m target specific extensions today for various cpu
>> insns), and ii) have the kernel check for presence of the extensions
>> and enable it transparently when the user selects more aggressive
>> options such as -march=native in a bpf target context, so we can
>> select the underlying features transparently. I should have made
>> that more clear earlier, sorry about that.
>
> I think this explanation needs to be in either your header posting
> or the commit message of patch #1.
>
> Thanks :)

Ok, sure, I'll do a v2 with that included. Thanks!
