From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tc: act_bpf: fix memory leak
Date: Wed, 15 Jul 2015 21:37:05 -0700 (PDT)
Message-ID: <20150715.213705.1466872612187912779.davem@davemloft.net>
References: <1436901319-705-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbbGPEhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:37:06 -0400
In-Reply-To: <1436901319-705-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 14 Jul 2015 12:15:19 -0700

> prog->bpf_ops is populated when act_bpf is used with classic BPF and
> prog->bpf_name is optionally used with extended BPF.
> Fix memory leak when act_bpf is released.
> 
> Fixes: d23b8ad8ab23 ("tc: add BPF based action")
> Fixes: a8cb5f556b56 ("act_bpf: add initial eBPF support for actions")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
