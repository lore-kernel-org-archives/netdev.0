From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22.3] ppp: fix output buffer size in
 ppp_decompress_frame
Date: Tue, 21 Aug 2007 00:13:23 -0700 (PDT)
Message-ID: <20070821.001323.55483148.davem@davemloft.net>
References: <1187343951.10629.9.camel@traveler>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msuresh_2001@yahoo.com, paulus@samba.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: konstantin.sharlaimov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbXHUHNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:13:25 -0400
In-Reply-To: <1187343951.10629.9.camel@traveler>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
Date: Fri, 17 Aug 2007 20:45:51 +1100

> This patch addresses the issue with "osize too small" errors in mppe encryption.
> The patch fixes the issue with wrong output buffer size being passed to ppp
> decompression routine.
> 
> Signed-off-by: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
> ---
> As pointed out by Suresh Mahalingam, the issue addressed by 
> ppp-fix-osize-too-small-errors-when-decoding patch is not fully resolved yet.
> The size of allocated output buffer is correct, however it size passed to
> ppp->rcomp->decompress in ppp_generic.c if wrong. The patch fixes that.

Patch applied, thanks.
