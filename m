From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/5] Various BPF fixes
Date: Thu, 25 May 2017 13:45:26 -0400 (EDT)
Message-ID: <20170525.134526.1519650285082936067.davem@davemloft.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        ecree@solarflare.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59978 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966687AbdEYRp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:45:28 -0400
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 25 May 2017 01:05:04 +0200

> Follow-up to fix incorrect pruning when alignment tracking is
> in use and to properly clear regs after call to not leave stale
> data behind, also a fix that adds bpf_clone_redirect to the
> bpf_helper_changes_pkt_data helper and exposes correct map_flags
> for lpm map into fdinfo. For details, please see individual
> patches.
> 
> v1 -> v2:
>   - Reworked first patch so that env->strict_alignment is the
>     final indicator on whether we have to deal with strict
>     alignment rather than having CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>     checks on various locations, so only checking env->strict_alignment
>     is sufficient after that. Thanks for spotting, Dave!
>   - Added patch 3 and 4.
>   - Rest as is.

Series applied, thanks Daniel.

Hmmm, this is likely to conflict with Edwards's work...
