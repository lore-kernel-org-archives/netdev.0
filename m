From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, seccomp: prepare for upcoming criu
 support
Date: Mon, 05 Oct 2015 06:53:30 -0700 (PDT)
Message-ID: <20151005.065330.932479433879939477.davem@davemloft.net>
References: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tycho.andersen@canonical.com,
	xemul@parallels.com, keescook@chromium.org, luto@amacapital.net,
	ast@plumgrid.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbbJENhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:37:52 -0400
In-Reply-To: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  2 Oct 2015 15:17:33 +0200

> The current ongoing effort to dump existing cBPF seccomp filters back
> to user space requires to hold the pre-transformed instructions like
> we do in case of socket filters from sk_attach_filter() side, so they
> can be reloaded in original form at a later point in time by utilities
> such as criu.
> 
> To prepare for this, simply extend the bpf_prog_create_from_user()
> API to hold a flag that tells whether we should store the original
> or not. Also, fanout filters could make use of that in future for
> things like diag. While fanout filters already use bpf_prog_destroy(),
> move seccomp over to them as well to handle original programs when
> present.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
