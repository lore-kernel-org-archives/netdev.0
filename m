From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/7] ebpf: export BPF_PSEUDO_MAP_FD to uapi
Date: Tue, 10 Feb 2015 17:39:35 -0800
Message-ID: <CAMEtUuzJGUzi5VysKDDcwUTcd0ro=pxB1iEn0aRQ5n+zfp5aXw@mail.gmail.com>
References: <cover.1423610452.git.daniel@iogearbox.net> <2b58ccd3ab577142297a7995fda7a065e51abef8.1423610452.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:65486 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbBKBj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 20:39:56 -0500
Received: by mail-qa0-f54.google.com with SMTP id x12so473385qac.13
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 17:39:55 -0800 (PST)
In-Reply-To: <2b58ccd3ab577142297a7995fda7a065e51abef8.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> We need to export BPF_PSEUDO_MAP_FD to user space, as it's used in
> the ELF BPF loader where instructions are being loaded that need
> map fixups (relocations). An initial stage loads all maps into the
> kernel, and later on replaces related instructions in the eBPF blob
> with BPF_PSEUDO_MAP_FD as source register and the actual fd as
> immediate value. The kernel verifier recognizes this keyword and
> replaces the map fd with a real pointer internally.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

oops. thanks. didn't realize that I forgot to add it to uapi.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
