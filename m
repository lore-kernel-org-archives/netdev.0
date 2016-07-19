From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon
 union initialization bug
Date: Tue, 19 Jul 2016 11:07:56 +0800
Message-ID: <20160719030756.GA28828@wfg-t540p.sh.intel.com>
References: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
 <20160719003305.GA45296@ast-mbp.thefacebook.com>
 <20160719003802.GA20768@wfg-t540p.sh.intel.com>
 <20160719023825.GA49474@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:43112 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbcGSDH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 23:07:59 -0400
Content-Disposition: inline
In-Reply-To: <20160719023825.GA49474@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 07:38:27PM -0700, Alexei Starovoitov wrote:
>On Tue, Jul 19, 2016 at 08:38:02AM +0800, Fengguang Wu wrote:
>> Hi Alexei,
>>
>> On Mon, Jul 18, 2016 at 05:33:07PM -0700, Alexei Starovoitov wrote:
>> >On Mon, Jul 18, 2016 at 03:50:58PM -0700, akpm@linux-foundation.org wrote:
>> >>From: Andrew Morton <akpm@linux-foundation.org>
>> >>Subject: kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon union initialization bug
>> >>
>> >>kernel/trace/bpf_trace.c: In function 'bpf_event_output':
>> >>kernel/trace/bpf_trace.c:312: error: unknown field 'next' specified in initializer
>> >>kernel/trace/bpf_trace.c:312: warning: missing braces around initializer
>> >>kernel/trace/bpf_trace.c:312: warning: (near initialization for 'raw.frag.<anonymous>')
>> >>
>> >>Fixes: 555c8a8623a3a87 ("bpf: avoid stack copy and use skb ctx for event output")
>> >>Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>> >>Cc: Alexei Starovoitov <ast@kernel.org>
>> >>Cc: David S. Miller <davem@davemloft.net>
>> >>Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> >
>> >Acked-by: Alexei Starovoitov <ast@kernel.org>
>> >
>> >Fengguang can you add gcc-4.4 to buildbot. Thanks!
>>
>> Sure. Currently we only test gcc-6. It'd be easy to test more versions
>> concurrently, like
>>
>> gcc-4.4
>> gcc-4.6
>> gcc-4.8
>> gcc-4.9
>> gcc-5
>> gcc-6
>
>thanks! If you need to reduce the test matrix I don't see a concern
>of dropping 4.6 and 4.8.
>4.4 is good for old stuff, 4.9 is the most stable and 5/6 are good
>for new warnings.

Not a burden at all. I've enabled them all. :)

Thanks,
Fengguang
