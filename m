From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
	include/linux/ip_vs.h
Date: Fri, 25 Jul 2008 10:22:21 +1000
Message-ID: <20080725002219.GC3896@verge.net.au>
References: <f4845fc0807240446k224215cn7aee7f57a0fa9100@mail.gmail.com> <1216900716-4448-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net, vbusam@google.com
To: Julius Volz <juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1216900716-4448-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2008 at 01:58:36PM +0200, Julius Volz wrote:
> Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
> directly. This file also contains kernel-only definitions. Normally, public
> definitions should live in include/linux, so this patch moves the
> definitions shared with userspace to a new file, "include/linux/ip_vs.h".
> 
> This also removes the unused NFC_IPVS_PROPERTY bitmask, which was once
> used to point into skb->nfcache.
> 
> To make old ipvsadms still compile with this, the old header file includes
> the new one.
> 
> Thanks to Dave Miller and Horms for noting/adding the missing Kbuild entry
> for the new header file.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

Acked-by: Simon Horman <horms@verge.net.au>

