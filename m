From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] bpf: x86: add missing 'shift by register' instructions
 to x64 eBPF JIT
Date: Mon, 25 Aug 2014 21:39:35 +0200
Message-ID: <53FB90F7.1000701@redhat.com>
References: <1408994822-14929-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045AbaHYTjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 15:39:44 -0400
In-Reply-To: <1408994822-14929-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2014 09:27 PM, Alexei Starovoitov wrote:
> 'shift by register' operations are supported by eBPF interpreter, but were
> accidently left out of x64 JIT compiler. Fix it and add a testcase.
>
> Reported-by: Brendan Gregg <brendan.d.gregg@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> ---
>
> Probably not worth sending to stable, but wouldn't hurt either.

Then I guess this should be against -net tree then.

I guess implications were only fallback to interpreter, right?
