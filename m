From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ebpf: allow bpf_ktime_get_ns_proto also
 for networking
Date: Sun, 31 May 2015 21:44:55 -0700 (PDT)
Message-ID: <20150531.214455.497864708663006246.davem@davemloft.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
	<cover.1432912637.git.daniel@iogearbox.net>
	<e37891545f298ab82d1bd7b62c16ff8f3f166534.1432912637.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, mingo@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbFAEo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:44:57 -0400
In-Reply-To: <e37891545f298ab82d1bd7b62c16ff8f3f166534.1432912637.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 29 May 2015 23:23:06 +0200

> As this is already exported from tracing side via commit d9847d310ab4
> ("tracing: Allow BPF programs to call bpf_ktime_get_ns()"), we might
> as well want to move it to the core, so also networking users can make
> use of it, e.g. to measure diffs for certain flows from ingress/egress.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
