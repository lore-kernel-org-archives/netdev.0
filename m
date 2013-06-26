From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 26 Jun 2013 08:07:37 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F603C48@DE02WEMBXB.internal.synopsys.com>
References: <20130626175610.8a8b6606fd9a5b6269398059@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2013 11:56 AM, Stephen Rothwell wrote:
> Hi all,
>
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
[]
> Caused by commit e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")
> from the net-next tree.
>
> I have reverted that commit for today.

I've just sent a patch that fixes reported issues (both errors and 
warnings).
===
[PATCH] arc_emac: fix compile-time errors & warnings on PPC64
===
So it could be merged with initial patch.

Or I may send another cumulative re-spin.

What's the best way?

Regards,
Alexey
