From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon
 union initialization bug
Date: Tue, 19 Jul 2016 08:38:02 +0800
Message-ID: <20160719003802.GA20768@wfg-t540p.sh.intel.com>
References: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
 <20160719003305.GA45296@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1511 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbcGSAiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 20:38:06 -0400
Content-Disposition: inline
In-Reply-To: <20160719003305.GA45296@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

On Mon, Jul 18, 2016 at 05:33:07PM -0700, Alexei Starovoitov wrote:
>On Mon, Jul 18, 2016 at 03:50:58PM -0700, akpm@linux-foundation.org wrote:
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Subject: kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon union initialization bug
>>
>> kernel/trace/bpf_trace.c: In function 'bpf_event_output':
>> kernel/trace/bpf_trace.c:312: error: unknown field 'next' specified in initializer
>> kernel/trace/bpf_trace.c:312: warning: missing braces around initializer
>> kernel/trace/bpf_trace.c:312: warning: (near initialization for 'raw.frag.<anonymous>')
>>
>> Fixes: 555c8a8623a3a87 ("bpf: avoid stack copy and use skb ctx for event output")
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
>Acked-by: Alexei Starovoitov <ast@kernel.org>
>
>Fengguang can you add gcc-4.4 to buildbot. Thanks!

Sure. Currently we only test gcc-6. It'd be easy to test more versions
concurrently, like

gcc-4.4
gcc-4.6
gcc-4.8
gcc-4.9
gcc-5
gcc-6

Thanks,
Fengguang
