From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] PPC: bpf_jit_comp: Unify BPF_MOD | BPF_X and
 BPF_DIV | BPF_X
Date: Tue, 18 Nov 2014 10:58:20 +0400
Message-ID: <CAOJe8K0_u51QkKmVoVmFuGaDtKfcHP6tSWx_fgJM_erRRoQfUA@mail.gmail.com>
References: <1416254861-3879-1-git-send-email-kda@linux-powerpc.org>
	<1416275444.1107.4.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:64523 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbaKRG6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 01:58:21 -0500
Received: by mail-yk0-f177.google.com with SMTP id 9so4711245ykp.8
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 22:58:21 -0800 (PST)
In-Reply-To: <1416275444.1107.4.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

This patch added no new functionality so I haven't put the test
results (of course I ran the test suite to check the patch).

The output :
[  650.198958] test_bpf: Summary: 60 PASSED, 0 FAILED

On 11/18/14, Michael Ellerman <mpe@ellerman.id.au> wrote:
> On Mon, 2014-11-17 at 23:07 +0300, Denis Kirjanov wrote:
>> Reduce duplicated code by unifying
>> BPF_ALU | BPF_MOD | BPF_X and BPF_ALU | BPF_DIV | BPF_X
>>
>> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
>> CC: Daniel Borkmann<dborkman@redhat.com>
>> CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>
> Please include the output of the test suite.
>
> Assuming that's OK I'm happy for it to go in.
>
> cheers
>
>
>
>
