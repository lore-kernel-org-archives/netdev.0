From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/2] act_bpf update
Date: Fri, 20 Mar 2015 22:10:36 +0100
Message-ID: <550C8CCC.7060901@iogearbox.net>
References: <cover.1426859241.git.daniel@iogearbox.net> <20150320.162252.977628965847070194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36928 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbCTVKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:10:39 -0400
In-Reply-To: <20150320.162252.977628965847070194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 03/20/2015 09:22 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 20 Mar 2015 15:11:10 +0100
>
>> This set adds native eBPF support also to act_bpf and thus covers tc
>> with eBPF in the classifier *and* action part.
>>
>> A link to iproute2 preview has been provided in patch 2 and the code
>> will be pushed out after Stephen has processed the classifier part
>> and helper bits for tc.
>>
>> This set depends on ced585c83b27 ("act_bpf: allow non-default TC_ACT
>> opcodes as BPF exec outcome"), so a net into net-next merge would be
>> required first. Hope that's fine by you, Dave. ;)
>>
>> Thanks a lot!
>
> Even with that commit, which is in net-next now, this series does
> not apply without rejects.
>
> Please respin.

So my HEAD is at latest net-next commit b4c11cb437fdb34b ("Merge branch
'amd-xgbe-next'"):

   $ git cherry-pick ced585c83b27deca427c606a34dd3eaa6b96d82b
   [ebpf-act 1b8dfa9] act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome
    1 file changed, 28 insertions(+), 8 deletions(-)
   $ git am 0001-ebpf-add-sched_act_type-and-map-it-to-sk_filter-s-ve.patch
   Applying: ebpf: add sched_act_type and map it to sk_filter's verifier ops
   $ git am 0002-act_bpf-add-initial-eBPF-support-for-actions.patch
   Applying: act_bpf: add initial eBPF support for actions
   $

The dependency mentioned in the cover letter is on net commit ced585c83b27
("act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome"). On my
side that applies fine, hm.

Thanks,
Daniel
