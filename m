From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH] lib/bpf: Fix bytecode-file parsing
Date: Fri, 01 Sep 2017 21:13:32 +0200
Message-ID: <59A9B15C.3060404@iogearbox.net>
References: <20170829150945.7077-1-phil@nwl.cc> <59A6C377.90705@iogearbox.net> <20170830141155.GH20614@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40577 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdIATNf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:13:35 -0400
In-Reply-To: <20170830141155.GH20614@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2017 04:11 PM, Phil Sutter wrote:
> On Wed, Aug 30, 2017 at 03:53:59PM +0200, Daniel Borkmann wrote:
>> On 08/29/2017 05:09 PM, Phil Sutter wrote:
[...]
>>
>> I don't really have a strong opinion on this, but the logic for
>> normalizing here is getting a bit convoluted. Is your use case
>> for making the parser more robust mainly so you can just use the
>> -ddd output from tcpdump for cBPF w/o piping through tr? But even
>> that shouldn't give multiple empty lines afaik, no?
>
> Well, using tcpdump output was functional before already. I just noticed
> that if I add an empty line to the end of bytecode-file, it will fail
> and I didn't like that. Then while searching for the EOF issue, I
> noticed that the parser logic above is a bit faulty in that it will
> treat different characters equally but doesn't make sure c_prev will be
> assigned only one of them. So apart from the added robustness, it really
> fixes an inconsistency in the parsing logic.

Ok, fine by me.
