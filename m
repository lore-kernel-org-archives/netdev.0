From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Tue, 29 Nov 2016 15:05:40 +0100
Message-ID: <c69b39de-60ad-8f88-a771-911dbca09f8b@zonque.org>
References: <1480145027-3524392-1-git-send-email-ast@fb.com>
 <583D5D00.4070101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:46760 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756906AbcK2OFo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 09:05:44 -0500
In-Reply-To: <583D5D00.4070101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 11:48 AM, Daniel Borkmann wrote:
> On 11/26/2016 08:23 AM, Alexei Starovoitov wrote:
>> this #include is unnecessary and brings whole set of
>> other headers into cgroup-defs.h. Remove it.
>>
>> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> 
> This fixes many build errors in samples/bpf/ due to wrong helper
> redefinitions (originating from kernel includes conflicting with
> samples' helper declarations).
> 
> I don't see it pushed out to net-next yet, so:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> 

FWIW:

Acked-by: Daniel Mack <daniel@zonque.org>
