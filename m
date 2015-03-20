From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 0/2] act_bpf update
Date: Fri, 20 Mar 2015 14:26:01 -0700
Message-ID: <550C9069.6000604@plumgrid.com>
References: <cover.1426859241.git.daniel@iogearbox.net> <20150320.162252.977628965847070194.davem@davemloft.net> <550C8CCC.7060901@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34599 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbbCTV0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:26:03 -0400
Received: by pacwe9 with SMTP id we9so120478037pac.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:26:03 -0700 (PDT)
In-Reply-To: <550C8CCC.7060901@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15 2:10 PM, Daniel Borkmann wrote:
>>
>>>
>>> This set depends on ced585c83b27 ("act_bpf: allow non-default TC_ACT
>>> opcodes as BPF exec outcome"), so a net into net-next merge would be
>>> required first. Hope that's fine by you, Dave. ;)
>>>
>>> Thanks a lot!
>>
>> Even with that commit, which is in net-next now, this series does
>> not apply without rejects.
>>
>> Please respin.
>
> So my HEAD is at latest net-next commit b4c11cb437fdb34b ("Merge branch
> 'amd-xgbe-next'"):
>
>    $ git cherry-pick ced585c83b27deca427c606a34dd3eaa6b96d82b
>    [ebpf-act 1b8dfa9] act_bpf: allow non-default TC_ACT opcodes as BPF
> exec outcome
>     1 file changed, 28 insertions(+), 8 deletions(-)
>    $ git am 0001-ebpf-add-sched_act_type-and-map-it-to-sk_filter-s-ve.patch
>    Applying: ebpf: add sched_act_type and map it to sk_filter's verifier
> ops
>    $ git am 0002-act_bpf-add-initial-eBPF-support-for-actions.patch
>    Applying: act_bpf: add initial eBPF support for actions
>    $
>
> The dependency mentioned in the cover letter is on net commit ced585c83b27
> ("act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome"). On my
> side that applies fine, hm.

I don't think 'net' has been merged into 'net-next' yet.
Or may be merged, but not pushed...
