From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Wed, 6 Jan 2016 19:53:35 -0800
Message-ID: <20160107035334.GA99020@ast-mbp.thefacebook.com>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jhs@mojatatu.com, john.fastabend@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34589 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbcAGDxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 22:53:32 -0500
Received: by mail-pa0-f50.google.com with SMTP id uo6so229214947pac.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 19:53:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2016 at 02:00:56AM +0100, Daniel Borkmann wrote:
> 
> I decided to extend the sch_ingress module with clsact functionality so
> that commonly used code can be reused, the module is being aliased with
> sch_clsact so that it can be auto-loaded properly. Alternative would have been
> to add a flag when initializing ingress to alter its behaviour plus aliasing
> to a different name (as it's more than just ingress). However, the first would
> end up, based on the flag, choosing the new/old behaviour by calling different
> function implementations to handle each anyway, the latter would require to
> register ingress qdisc once again under different alias. So, this really begs
> to provide a minimal, cleaner approach to have Qdisc_ops and Qdisc_class_ops
> by its own that share callbacks used by both.
...
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

we've been going back and forth on the design and this final approach
presented seems to be the best, since pros outweigh the cons.

Acked-by: Alexei Starovoitov <ast@kernel.org>
