From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 22:11:29 -0400 (EDT)
Message-ID: <20170429.221129.1940993396042409828.davem@davemloft.net>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
        <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965204AbdD3CLd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:11:33 -0400
In-Reply-To: <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 17:48:43 -0700

> On 4/28/17 1:33 PM, David Miller wrote:
>> New in this version:
>>
>> 1) All the relocation work I posted earlier today.
>> 2) Teach readelf about a few bpf relocs as needed
>> 3) Add a 'nop' instruction which facilitates the gas
>>    testsuite.  I used "mov r0,r0"
>>
>> The whole gas testsuite passes now. :-)  But that just
>> means we have to add more tests I guess....
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> it seems by default bpf target is not enabled,
> so I tried to build it with:
> ../configure --enable-targets=bpf,x86

Please use "--target=bpf-elf"
