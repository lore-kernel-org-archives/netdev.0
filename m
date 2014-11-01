From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Sat, 01 Nov 2014 14:00:35 -0400 (EDT)
Message-ID: <20141101.140035.13626854970331774.davem@davemloft.net>
References: <CAOJe8K31iB9+7c1BnS=6DdriU08WUisM7sYgj8nOBo4Fg=XUBg@mail.gmail.com>
	<20141101.133957.1365371956675094081.davem@davemloft.net>
	<CAOJe8K2FzuPTZ5pch8_UK7X==+=k8RKLnfz0mZb2hca19aU4pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, mpe@ellerman.id.au, matt@ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbaKASAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 14:00:38 -0400
In-Reply-To: <CAOJe8K2FzuPTZ5pch8_UK7X==+=k8RKLnfz0mZb2hca19aU4pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Sat, 1 Nov 2014 21:49:27 +0400

> David, you need a feedback from other guys to apply this patch, right?
> 
> Alexei wanted some output before/after the patch.
> Michael Ellerman wanted the explanation what a BPF_ANC | SKF_AD_PKTTYPE means.
> So I'm waiting  the ack/nack from them...

I don't really think performance metrics are necessary just for adding
SKF_AD_PKTTYPE support, that's sort of an over the top requirement
if you ask me.

It's pretty obvious that we should support as many operations as
possible to each JIT, because all of program has to do is use that
unsupported opcode and then we have none of that program being JIT'd.
