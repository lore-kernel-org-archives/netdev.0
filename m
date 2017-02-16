From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 15 Feb 2017 22:27:46 -0500 (EST)
Message-ID: <20170215.222746.1747689327951875592.davem@davemloft.net>
References: <20170214091250.57d054b2@canb.auug.org.au>
        <20170216140215.69d39914@canb.auug.org.au>
        <58A5171A.8080604@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
        linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        peterz@infradead.org, mingo@redhat.com, acme@kernel.org,
        alexander.shishkin@linux.intel.com, joe@ovn.org, jolsa@redhat.com
To: ast@fb.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <58A5171A.8080604@fb.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 15 Feb 2017 19:06:02 -0800

> On 2/15/17 7:02 PM, Stephen Rothwell wrote:
>> Hi all,
>>
>> On Tue, 14 Feb 2017 09:12:50 +1100 Stephen Rothwell
>> <sfr@canb.auug.org.au> wrote:
>>>
>>> After merging the net tree, today's linux-next build (powerpc64le
>>> perf)
>>> failed like this:
>>>
>>> Warning: tools/include/uapi/linux/bpf.h differs from kernel
>>> bpf.c: In function 'bpf_prog_attach':
>>> bpf.c:180:6: error: 'union bpf_attr' has no member named
>>> 'attach_flags'; did you mean 'map_flags'?
>>>    attr.attach_flags  = flags;
>>>        ^
>>>
>>> Caused by commit
>>>
>>>    7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")
>>>
>>
>> So do we have a fix for this?  I am sure that Dave would like to send
>> his "net" tree to Linus sometime soonish ...
> 
> Do you mind resending it to netdev with my Ack ?
> please mention [PATCH net] in subj, so it's get caught by Dave's
> scripts.

I applied the fix that synced the two header files already.
