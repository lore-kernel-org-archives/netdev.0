From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] m_bpf: don't require default opcode on
 ebpf actions
Date: Mon, 12 Oct 2015 09:45:32 -0700
Message-ID: <20151012094532.1c348b05@urahara>
References: <605ab2e3b1957b5f268214b165b7b27a527ee3a9.1444307491.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35996 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbJLQpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:45:19 -0400
Received: by pacex6 with SMTP id ex6so4384207pac.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:45:19 -0700 (PDT)
In-Reply-To: <605ab2e3b1957b5f268214b165b7b27a527ee3a9.1444307491.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Oct 2015 15:22:05 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> After the patch, the most minimal command to load an eBPF action
> for late binding with auto index selection through tc is:
> 
>   tc actions add action bpf obj prog.o
> 
> We already set TC_ACT_PIPE in tc as default opcode, so if nothing
> further has been specified, just use it. Also, allow "ok" next to
> "pass" for matching cmdline on TC_ACT_OK.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next
