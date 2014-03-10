From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] x86: bpf_jit: support negative offsets
Date: Mon, 10 Mar 2014 16:13:02 -0700
Message-ID: <1394493182.3607.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jan Seiffert <kaffeemonster@googlemail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34538 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbaCJXNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 19:13:09 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so7986831pab.33
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 16:13:08 -0700 (PDT)
In-Reply-To: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 15:56 -0700, Alexei Starovoitov wrote:
> Commit a998d4342337 claimed to introduce negative offset support to x86 jit,
> but it couldn't be working, since at the time of the execution
> of LD+ABS or LD+IND instructions via call into
> bpf_internal_load_pointer_neg_helper() the %edx (3rd argument of this func)
> had junk value instead of access size in bytes (1 or 2 or 4).
> 
> Store size into %edx instead of %ecx (what original commit intended to do)
> 
> Fixes: a998d4342337 ("bpf jit: Let the x86 jit handle negative offsets")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jan Seiffert <kaffeemonster@googlemail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> --
> This is a single bit patch. Is there a leaderboard of shortest patches? ;)

Acked-by: Eric Dumazet <edumazet@google.com>

Its actually a 1 byte or 3-bit patch ;)

'c' is 0x63, and 'd' is 0x64 ;)
