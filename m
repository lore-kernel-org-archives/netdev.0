From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/7] ebpf: remove kernel test stubs
Date: Tue, 10 Feb 2015 16:42:13 -0800
Message-ID: <CAMEtUuwPNZdDaAZb67Sev2XmnwsdAyO4O5r7hWwaPsONoTYu6Q@mail.gmail.com>
References: <cover.1423610452.git.daniel@iogearbox.net> <0772f0348f40e517e19a838877f417b8932b95a9.1423610452.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:52069 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbBKAme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:42:34 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so374146qab.2
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:42:33 -0800 (PST)
In-Reply-To: <0772f0348f40e517e19a838877f417b8932b95a9.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Now that we have BPF_PROG_TYPE_SOCKET_FILTER up and running,
> we can remove the test stubs which were added to get the
> verifier suite up. We can just let the test cases probe under
> socket filter type instead. In the fill/spill test case, we
> cannot (yet) access fields from the context (skb), but we may
> adapt that test case in future.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

has been on my todo list for a while. Thanks a bunch!
