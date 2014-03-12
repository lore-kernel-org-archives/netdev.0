From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] x86: bpf_jit: support negative offsets
Date: Tue, 11 Mar 2014 23:26:08 -0400 (EDT)
Message-ID: <20140311.232608.1193651497868512588.davem@davemloft.net>
References: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, edumazet@google.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbaCLD0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 23:26:10 -0400
In-Reply-To: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 10 Mar 2014 15:56:51 -0700

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

Applied and queued up for -stable, thanks.
