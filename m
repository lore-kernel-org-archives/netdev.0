From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon, 1 Dec 2014 17:55:38 +0400
Message-ID: <CAOJe8K16q6T7z2C3SOhD-be5oM1AMfxtkv6BA2ruEFvYAbkuSA@mail.gmail.com>
References: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
	<547C7240.4010401@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, markos.chandras@imgtec.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:61531 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbaLANzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 08:55:39 -0500
Received: by mail-yh0-f51.google.com with SMTP id a41so4874943yho.10
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 05:55:39 -0800 (PST)
In-Reply-To: <547C7240.4010401@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/14, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 12/1/2014 12:57 PM, Denis Kirjanov wrote:
>
>     You should CC the 'linux-mips' ML.
>
>> Remove optimize_div() from BPF_MOD | BPF_K case
>> since we don't know the dividend and fix the
>> emit_mod() by reading the mod operation result from HI register
>
>     Isn't this 2 unrelated fixes? They should be in 2 patches, not a single
>
> one in that case.
>

They do fix the BPD_MOD _single_ case.  I don't think that it's a good
reason here to split  the fin in 2 patches

>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>   arch/mips/net/bpf_jit.c |    4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> WBR, Sergei
>
>
