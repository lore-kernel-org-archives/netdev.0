From: David Miller <davem@davemloft.net>
Subject: Re: Bug in ks8851.c
Date: Fri, 29 Mar 2013 15:43:48 -0400 (EDT)
Message-ID: <20130329.154348.1417472944436998499.davem@davemloft.net>
References: <OF2DFE75BF.1BA5B9C8-ON44257B3D.00492A11-44257B3D.0049472A@gb.elster.com>
	<CAOJe8K1LbPgBN5kgXF5W2Fg_JM0BGp69+auSZ6Nk+3appmXZOg@mail.gmail.com>
	<OF95B2AB6A.BE754AB4-ON44257B3D.00544464-44257B3D.0054ECCB@gb.elster.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, gerg@uclinux.org, jiri@resnulli.us,
	linus971@gmail.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, mjr@cs.wisc.edu,
	netdev@vger.kernel.org, sboyd@codeaurora.org,
	torvalds@linux-foundation.org
To: Max.Nekludov@us.elster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab3C2Tnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:43:52 -0400
In-Reply-To: <OF95B2AB6A.BE754AB4-ON44257B3D.00544464-44257B3D.0054ECCB@gb.elster.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max.Nekludov@us.elster.com
Date: Fri, 29 Mar 2013 19:27:36 +0400

> Denis,
> here is patch with commit message:
> 
> Subject: [PATCH] Fix bug in ks8851 driver
> 
> According to the Datasheet (page 52):
> 15-12 Reserved
> 11-0 RXBC Receive Byte Count
> This field indicates the present received frame byte size.
> 
> The code has a bug:
>                  rxh = ks8851_rdreg32(ks, KS_RXFHSR);
>                  rxstat = rxh & 0xffff;
>                  rxlen = rxh >> 16; // BUG!!! 0xFFF mask should be applied
> 
> Signed-off-by: Max Nekludov <Max.Nekludov@us.elster.com>

Applied and queued up for -stable, thanks.
