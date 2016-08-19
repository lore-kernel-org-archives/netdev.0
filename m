From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/2] qdisc-hashtable fixes
Date: Thu, 18 Aug 2016 21:19:24 -0700 (PDT)
Message-ID: <20160818.211924.685863058808736843.davem@davemloft.net>
References: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, dsa@cumulusnetworks.com,
        simon.horman@netronome.com, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, jhs@mojatatu.com, phil@nwl.cc,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jikos@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jikos@kernel.org>
Date: Tue, 16 Aug 2016 23:52:08 +0200 (CEST)

> The following two patches fix all the issues that have been reported 
> against the conversion of qdisc linked list to hashtable (currently in 
> net-next) so far.
> 
> First patch adjusts handling of singleton qdiscs to the new semantics, and 
> is rather straightforward.
> 
> The second patch, which fixes "cosmetic" issue of duplicate entries in the 
> qdisc dump for ingress qdiscs, is a little bit more hairy; I personally 
> would love to see all the already existing "if (ingress)"-like hacks go 
> away (by, let's say, introducing a general TCQ_F_? flag), but that's way 
> out of scope of this patchset (but already on my todo).
> 
> Thanks a lot to Daniel Borkmann and David Ahern for reporting the issues 
> and testing the patches promptly.

Series applied, thanks Jiri.
