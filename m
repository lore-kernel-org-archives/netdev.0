From: Alexei Starovoitov <ast@fb.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 15 Feb 2017 19:06:02 -0800
Message-ID: <58A5171A.8080604@fb.com>
References: <20170214091250.57d054b2@canb.auug.org.au>
 <20170216140215.69d39914@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Peter Zijlstra" <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        "Arnaldo Carvalho de Melo" <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Joe Stringer <joe@ovn.org>, Jiri Olsa <jolsa@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57666 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751837AbdBPDHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 22:07:11 -0500
In-Reply-To: <20170216140215.69d39914@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/17 7:02 PM, Stephen Rothwell wrote:
> Hi all,
>
> On Tue, 14 Feb 2017 09:12:50 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>>
>> After merging the net tree, today's linux-next build (powerpc64le perf)
>> failed like this:
>>
>> Warning: tools/include/uapi/linux/bpf.h differs from kernel
>> bpf.c: In function 'bpf_prog_attach':
>> bpf.c:180:6: error: 'union bpf_attr' has no member named 'attach_flags'; did you mean 'map_flags'?
>>    attr.attach_flags  = flags;
>>        ^
>>
>> Caused by commit
>>
>>    7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")
>>
>
> So do we have a fix for this?  I am sure that Dave would like to send
> his "net" tree to Linus sometime soonish ...

Do you mind resending it to netdev with my Ack ?
please mention [PATCH net] in subj, so it's get caught by Dave's scripts.
