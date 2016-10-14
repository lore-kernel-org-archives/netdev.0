From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH v3] IB/ipoib: move back IB LL address into the hard
 header
Date: Fri, 14 Oct 2016 16:48:50 +0200
Message-ID: <1476456530.5591.1.camel@redhat.com>
References: <9fce9b87ecc4c5c4f03401359806f40b1dcd0eb3.1476374992.git.pabeni@redhat.com>
         <CAJ3xEMi7DY7_3vM+553dC4w17W==CdUdtn5PdzzCCUxtj434dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "talal@mellanox.com" <talal@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752742AbcJNOsz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 10:48:55 -0400
In-Reply-To: <CAJ3xEMi7DY7_3vM+553dC4w17W==CdUdtn5PdzzCCUxtj434dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-14 at 13:23 +0300, Or Gerlitz wrote:
> 
> Paolo,
> 
> Is this fix backportable to any kernel since the breakage? 

yes, AFAIK this is beck-portable.

> AFAIR,
> Roland mentioned
> that a 2nd change introduced in 4.7-rc1 changed things a bit more such
> that the fix
> he had in his head didn't apply any more.

If you refer to shrinking both IPoIB and gso control buffer, as proposed
by Roland in:

http://marc.info/?l=linux-kernel&m=146787279825501&w=2

that will not work, since the gso control buffer is grown a bit since
the first time the bug was detected.

This patch does not have that sort of issue.

> I am still travelling after netdev and would like to put an eye on the
> patch and also see that @mellanox.com someone

Not sure if that helps, but a 3rd party has already confirmed privately
that this patch fixes the bug for them.

Paolo
