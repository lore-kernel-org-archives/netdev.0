From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 1/2] firewire: net: fix maximum possible MTU
Date: Sun, 23 Oct 2016 21:50:39 -0400
Message-ID: <20161024015039.GC42084@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-8-jarod@redhat.com>
 <20161022211606.3b5d137d@kant>
 <20161022212759.228c7642@kant>
 <20161023011824.GE32569@redhat.com>
 <20161023162903.4166a35d@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux1394-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161023162903.4166a35d@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 23, 2016 at 04:29:03PM +0200, Stefan Richter wrote:
> Commit b3e3893e1253 ("net: use core MTU range checking in misc drivers")
> mistakenly introduced an upper limit for firewire-net's MTU based on the
> local link layer controller's reception capability.  Revert this.  Neither
> RFC 2734 nor our implementation impose any particular upper limit.
> 
> Actually, to be on the safe side and to make the code explicit, set
> ETH_MAX_MTU = 65535 as upper limit now.
> 
> (I replaced sizeof(struct rfc2734_header) by the equivalent
> RFC2374_FRAG_HDR_SIZE in order to avoid distracting long/int conversions.)
> 
> Fixes: b3e3893e1253('net: use core MTU range checking in misc drivers')
> CC: netdev@vger.kernel.org
> CC: linux1394-devel@lists.sourceforge.net
> CC: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

Acked-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
