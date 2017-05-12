From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Fri, 12 May 2017 17:17:55 +0200
Message-ID: <20170512151755.GB32630@lunn.ch>
References: <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
 <20170511.212940.1950696136811799858.davem@davemloft.net>
 <0aab1aec-814c-e496-4254-ca33a81f8c7f@fb.com>
 <20170512.104624.902298156565692816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56738 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933062AbdELPSE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 12 May 2017 11:18:04 -0400
Content-Disposition: inline
In-Reply-To: <20170512.104624.902298156565692816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 10:46:24AM -0400, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Thu, 11 May 2017 22:07:04 -0700
> 
> > On 5/11/17 6:29 PM, David Miller wrote:
> >> This whole thing go me thinking however.  What do you expect to happen
> >> on 32-bit architectures implementing an eBPF JIT?
> > 
> > I doubt any 32-bit cpu architectures will do JIT in the near future.
> 
> ARM 32-bit is being implemented as we speak, in fact it's been discussed
> on this very list over the past week.

It could be XDP is interesting on small embedded systems, i.e ARM32
and MIPS, used in WiFi access points and the like. I've heard it said
that the Linux network stack has become too big to run well on these
systems, it no longer fits in the instruction cache. It would be
interesting to see if XDP/eBPF can be used for handling part of the
packet load without thrashing the instruction cache.

       Andrew
