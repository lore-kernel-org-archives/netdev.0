From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net v2 2/2] xdp: refine xdp api with regards to generic
 xdp
Date: Thu, 11 May 2017 17:13:20 -0700
Message-ID: <20170511171320.657fb52f@cakuba.netronome.com>
References: <cover.1494542162.git.daniel@iogearbox.net>
        <fe08e3c98d6c473d77b14a323abbd41c1e7d8f6d.1494542162.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:59843 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756730AbdELANo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 11 May 2017 20:13:44 -0400
In-Reply-To: <fe08e3c98d6c473d77b14a323abbd41c1e7d8f6d.1494542162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 May 2017 01:04:46 +0200, Daniel Borkmann wrote:
> For the dump, remove IFLA_XDP_FLAGS that was added with b5cdae3291f7
> and reuse IFLA_XDP_ATTACHED for indicating the mode. Dumping all
> or just a subset of flags that were used for loading the XDP prog
> is suboptimal in the long run since not all flags are useful for
> dumping and if we start to reuse the same flag definitions for
> load and dump, then we'll waste bit space. What we really just
> want is to dump the mode for now.
> 
> Current IFLA_XDP_ATTACHED semantics are: nothing was installed (0),
> a program is running at the native driver layer (1). Thus, add a
> mode that says that a program is running at generic XDP layer (2).
> Applications will handle this fine in that older binaries will
> just indicate that something is attached at XDP layer, effectively
> this is similar to IFLA_XDP_FLAGS attr that we would have had
> modulo the redundancy.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Looks good to me, thanks!
