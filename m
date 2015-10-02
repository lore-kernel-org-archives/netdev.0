From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, seccomp: prepare for upcoming criu support
Date: Fri, 02 Oct 2015 17:21:33 +0200
Message-ID: <560EA0FD.30406@iogearbox.net>
References: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net> <560E9E3E.2080000@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41244 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbbJBPVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 11:21:35 -0400
In-Reply-To: <560E9E3E.2080000@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2015 05:09 PM, Alexei Starovoitov wrote:
...
> I agree that adding flag to bpf_prog_create_from_user() is cleaner
> than exposing static bpf_prog_store_orig_filter(), so

There's also another reason as mentioned, i.e. that the progs
are ro-locked, so doing bpf_prog_store_orig_filter() after getting
the prog back inside seccomp won't work as-is.

> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Thanks,
Daniel
