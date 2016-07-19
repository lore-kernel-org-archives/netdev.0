From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon
 union initialization bug
Date: Tue, 19 Jul 2016 10:19:06 +0200
Message-ID: <578DE27A.2090906@iogearbox.net>
References: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org> <20160719003305.GA45296@ast-mbp.thefacebook.com> <20160719003802.GA20768@wfg-t540p.sh.intel.com> <20160719023825.GA49474@ast-mbp.thefacebook.com> <20160719030756.GA28828@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33041 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbcGSITQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 04:19:16 -0400
In-Reply-To: <20160719030756.GA28828@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 05:07 AM, Fengguang Wu wrote:
> On Mon, Jul 18, 2016 at 07:38:27PM -0700, Alexei Starovoitov wrote:
>> On Tue, Jul 19, 2016 at 08:38:02AM +0800, Fengguang Wu wrote:
>>> On Mon, Jul 18, 2016 at 05:33:07PM -0700, Alexei Starovoitov wrote:
[...]
>>> >Fengguang can you add gcc-4.4 to buildbot. Thanks!
>>>
>>> Sure. Currently we only test gcc-6. It'd be easy to test more versions
>>> concurrently, like
>>>
>>> gcc-4.4
>>> gcc-4.6
>>> gcc-4.8
>>> gcc-4.9
>>> gcc-5
>>> gcc-6
>>
>> thanks! If you need to reduce the test matrix I don't see a concern
>> of dropping 4.6 and 4.8.
>> 4.4 is good for old stuff, 4.9 is the most stable and 5/6 are good
>> for new warnings.
>
> Not a burden at all. I've enabled them all. :)

Nice, thanks a lot Fengguang!
