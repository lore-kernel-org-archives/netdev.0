From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 0/3 net-next] xen-netback: guest Rx queue
 drain and stall fixes
Date: Sat, 25 Oct 2014 14:14:01 -0400 (EDT)
Message-ID: <20141025.141401.1122447572448682731.davem@davemloft.net>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org
To: david.vrabel@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 22 Oct 2014 14:08:52 +0100

> This series fixes two critical xen-netback bugs.
> 
> 1. Netback may consume all of host memory by queuing an unlimited
>    number of skb on the internal guest Rx queue.  This behaviour is
>    guest triggerable.
> 
> 2. Carrier flapping under high traffic rates which reduces
>    performance.
> 
> The first patch is a prerequite.  Removing support for frontends with
> feature-rx-notify makes it easier to reason about the correctness of
> netback since it no longer has to support this outdated and broken
> mode.

Series applied to net-next, thanks.
