From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] silence warnings when building kernel/bpf/core.c with
 W=1
Date: Sun, 31 Jul 2016 20:35:21 -0700 (PDT)
Message-ID: <20160731.203521.1326608781544696617.davem@davemloft.net>
References: <8434.1470022053@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbcHADfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:35:22 -0400
In-Reply-To: <8434.1470022053@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Sun, 31 Jul 2016 23:27:33 -0400

> Building with W=1 generates some 350 lines of warnings of the form:
> 
> kernel/bpf/core.c: In function '__bpf_prog_run':
> kernel/bpf/core.c:476:33: warning: initialized field overwritten [-Woverride-init]
>    [BPF_ALU | BPF_ADD | BPF_X] = &&ALU_ADD_X,
>                                  ^~
> kernel/bpf/core.c:476:33: note: (near initialization for 'jumptable[12]')
> 
> Since they come from the way we intentionally build the table, silence
> that one specific warning.
> 
> Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

Patch submission must use a proper subsystem prefix in their Subject lines,
as this ends up in the kernel commit shortlog.

The appropriate subsystem prefix for this patch is "bpf: "
