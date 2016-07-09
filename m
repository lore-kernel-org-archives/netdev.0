From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: introduce bpf_get_current_task() helper
Date: Sat, 09 Jul 2016 00:00:41 -0400 (EDT)
Message-ID: <20160709.000041.1085148162187281843.davem@davemloft.net>
References: <1467869916-2313494-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, brendan.d.gregg@gmail.com,
	netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbcGIEBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 00:01:24 -0400
In-Reply-To: <1467869916-2313494-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 6 Jul 2016 22:38:36 -0700

> over time there were multiple requests to access different data
> structures and fields of task_struct current, so finally add
> the helper to access 'current' as-is. Tracing bpf programs will do
> the rest of walking the pointers via bpf_probe_read().
> Note that current can be null and bpf program has to deal it with,
> but even dumb passing null into bpf_probe_read() is still safe.
> 
> Suggested-by: Brendan Gregg <brendan.d.gregg@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
