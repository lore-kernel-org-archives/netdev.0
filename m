From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, seccomp: prepare for upcoming criu support
Date: Fri, 02 Oct 2015 17:17:26 +0200
Message-ID: <560EA006.2000306@iogearbox.net>
References: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net> <20151002150603.GM23065@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40939 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbJBPRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 11:17:31 -0400
In-Reply-To: <20151002150603.GM23065@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2015 05:06 PM, Tycho Andersen wrote:
...
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>>   This is in realtion to Tycho's latest patch set under [1]. The BPF
>>   handling is unfortunately not correct (triggering a crash on kernels
>>   that can set pages as ro).
>>
>>   This patch here provides a minimal, simple interface from BPF API side
>>   as a possible step forward, so that the focus can then be on seccomp
>>   side wrt criu. F.e., dumping could happen similarly as in Pavel's
>>   sk_get_filter().
>>
>>   I have tested/based this against net-next, but have no issues whether
>>   Kees wants to take it, or whether it should go through both trees to
>>   reduce merge issues as once the case with 0fc174dea545 ("ebpf: make
>>   internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs").
>
> I'll send out a revised version of my set with Andy's comments later
> today and not include this patch. Let me know if I should do something
> differently.

Should be okay.

Please make sure to describe in your cover letter that your series builds
on top of ...

   http://patchwork.ozlabs.org/patch/525492/

... so that whoever takes the set eventually is aware of this.

Thanks again,
Daniel
