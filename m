From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/5 v4] netfilter: Fix format string of nfnetlink_queue
 proc file
Date: Mon, 13 Apr 2015 20:43:34 +0200
Message-ID: <20150413184334.GB3333@salvia>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
 <1428879159-19237-4-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1428879159-19237-4-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 12:52:38AM +0200, Richard Weinberger wrote:
> The printed values are all of type unsigned integer, therefore use
> %u instead of %d. Otherwise an user can face negative values.
> 
> Fixes:
> $ cat /proc/net/netfilter/nfnetlink_queue
>     0  29508   278 2 65531     0 2004213241 -2129885586  1
>     1 -27747     0 2 65531     0     0        0  1
>     2 -27748     0 2 65531     0     0        0  1
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
