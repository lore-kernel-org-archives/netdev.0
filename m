From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86 bpf_jit: support BPF_S_ANC_ALU_XOR_X
 instruction
Date: Wed, 06 Jun 2012 09:44:47 -0700 (PDT)
Message-ID: <20120606.094447.1811177386521216572.davem@davemloft.net>
References: <1338881190.2760.1992.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com, mgherzan@gmail.com,
	matt@ozlabs.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318Ab2FFQos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 12:44:48 -0400
In-Reply-To: <1338881190.2760.1992.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jun 2012 09:26:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit ffe06c17afbb  (filter: add XOR operation) added generic support
> for XOR operation.
> 
> This patch implements the XOR instruction in x86 jit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Eric.  I'll take care of Sparc.

ARM and POWERPC folks, this is just a reminder for you guys
to do this too.  Adding support for XOR to your JITs ought to
be quite trivial.

Thanks.
