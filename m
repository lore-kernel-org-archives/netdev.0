From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Tue, 02 May 2017 22:30:55 +0200
Message-ID: <5908EC7F.5070208@iogearbox.net>
References: <149372826543.22268.3617359219409721129.stgit@firesoul> <20170502.154014.2024927301583088718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: David Miller <davem@davemloft.net>, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56901 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751005AbdEBUbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 16:31:04 -0400
In-Reply-To: <20170502.154014.2024927301583088718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2017 09:40 PM, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Tue, 02 May 2017 14:31:45 +0200
>
>> This series improves and fixes bpf ELF loader and programs under
>> samples/bpf.  The bpf_load.c created some hard to debug issues when
>> the struct (bpf_map_def) used in the ELF maps section format changed
>> in commit fb30d4b71214 ("bpf: Add tests for map-in-map").
>>
>> This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
>> detect and abort if ELF maps section size is wrong") by detecting the
>> issue and aborting the program.
>>
>> In most situations the bpf-loader should be able to handle these kind
>> of changes to the struct size.  This patch series aim to do proper
>> backward and forward compabilility handling when loading ELF files.
>>
>> This series also adjust the callback that was introduced in commit
>> 9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
>> bpf_map_def") to use the new bpf_map_data structure, before more users
>> start to use this callback.
>>
>> Hoping these changes can make the merge window, as above mentioned
>> commits have not been merged yet, and it would be good to avoid users
>> hitting these issues.
>
> Alexei and Daniel, please review.

I'm on it.
