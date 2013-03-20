From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/4] filter: add minimal BPF JIT emitted image
 disassembler
Date: Wed, 20 Mar 2013 02:58:34 +0000
Message-ID: <1363748314.31336.30.camel@deadeye.wl.decadent.org.uk>
References: <cover.1363699285.git.dborkman@redhat.com>
	 <8d8079d7a5cffe05eeb44a35cb5d7c3544a84f4f.1363699285.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60191 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3CTC6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 22:58:40 -0400
In-Reply-To: <8d8079d7a5cffe05eeb44a35cb5d7c3544a84f4f.1363699285.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 14:28 +0100, Daniel Borkmann wrote:
> This is a minimal stand-alone user space helper, that allows for debugging or
> verification of emitted BPF JIT images. This is in particular useful for
> emitted opcode debugging, since minor bugs in the JIT compiler can be fatal.
> The disassembler is architecture generic and uses libopcodes and libbfd.
[...]
> ---
>  scripts/bpf_jit_disasm.c | 216 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 216 insertions(+)
>  create mode 100644 scripts/bpf_jit_disasm.c
[...]

This might belong in tools.  scripts is mostly for build scripts now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
