From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 19:03:03 +0200
Message-ID: <598B4047.2090701@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>        <cover.1502272924.git.daniel@iogearbox.net>        <63b41a38e0d58536700c999ade7c2c267bd2613d.1502272924.git.daniel@iogearbox.net> <20170809.095553.268665355274669790.davem@davemloft.net> <598B3FCA.7060904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37699 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754232AbdHIRDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 13:03:08 -0400
In-Reply-To: <598B3FCA.7060904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2017 07:00 PM, Daniel Borkmann wrote:
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

(In other words the one I used for doing the measurements.)
