From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next 0/6] bpf: Enable BPF JIT on ppc32
Date: Mon, 16 Feb 2015 11:13:56 +0400
Message-ID: <CAOJe8K380m94BL=YX6NFE1m7w3VpW8uORfttO36=r99FnoZdNg@mail.gmail.com>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
	<54E0FCEF.6090701@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, mpe@ellerman.id.au, ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:56694 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbBPHN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 02:13:57 -0500
Received: by mail-yk0-f174.google.com with SMTP id 9so12532263ykp.5
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 23:13:56 -0800 (PST)
In-Reply-To: <54E0FCEF.6090701@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/15, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/15/2015 07:06 PM, Denis Kirjanov wrote:
>> This patch series enables BPF JIT on ppc32. There are relatevily
>> few chnages in the code to make it work.
>>
>> All test_bpf tests passed both on 7447a and P2041-based machines.
>
> I'm just wondering, next to the feedback that has already been
> provided, would opening this up for ppc32 make it significantly
> more difficult in future to migrate from classic BPF JIT to eBPF
> JIT eventually (which is what we want long-term)? Being curious,
> is there any ongoing effort from ppc people?
>

Well, I don't see significant challenges to enable eBPF on ppc64 in the future.
I'll start working on it after I get this merged
