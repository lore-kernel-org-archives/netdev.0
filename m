From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [XFRM] AUDIT: Fix audit buffer leakage in error path.
Date: Tue, 13 Feb 2007 08:40:29 +0900 (JST)
Message-ID: <20070213.084029.08927594.yoshfuji@linux-ipv6.org>
References: <20070213.003429.73173216.yoshfuji@linux-ipv6.org>
	<20070212.152317.92582928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54496 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030497AbXBLXk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:40:27 -0500
In-Reply-To: <20070212.152317.92582928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070212.152317.92582928.davem@davemloft.net> (at Mon, 12 Feb 2007 15:23:17 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 13 Feb 2007 00:34:29 +0900 (JST)
> 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Oh yes.  I noticed this too while working with Joy Latten's OOPS fix
> for this function.
> 
> Event types other than those 4 mentioned in the switch() statement are
> illegal and should never be passed in.  It is probably better to BUG()
> on this situation rather than try to handle the log buffer leakage.

Okay, I agree and I withdraw my patch.

--yoshfuji
