From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Fri, 12 May 2017 10:46:24 -0400 (EDT)
Message-ID: <20170512.104624.902298156565692816.davem@davemloft.net>
References: <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
        <20170511.212940.1950696136811799858.davem@davemloft.net>
        <0aab1aec-814c-e496-4254-ca33a81f8c7f@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756241AbdELOq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 10:46:28 -0400
In-Reply-To: <0aab1aec-814c-e496-4254-ca33a81f8c7f@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 11 May 2017 22:07:04 -0700

> On 5/11/17 6:29 PM, David Miller wrote:
>> This whole thing go me thinking however.  What do you expect to happen
>> on 32-bit architectures implementing an eBPF JIT?
> 
> I doubt any 32-bit cpu architectures will do JIT in the near future.

ARM 32-bit is being implemented as we speak, in fact it's been discussed
on this very list over the past week.
