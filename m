From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/13] ppp: handle kmalloc() failures
Date: Tue, 15 Aug 2006 00:09:56 -0700 (PDT)
Message-ID: <20060815.000956.51842385.davem@davemloft.net>
References: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takis@issaris.org, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20404
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965245AbWHOHJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:09:54 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:38 -0700

> From: Panagiotis Issaris <takis@issaris.org>
> 
> The PPP code contains two kmalloc()s followed by memset()s without handling a
> possible memory allocation failure.  (Suggested by Joe Perches).
> 
> And furthermore, conversions from kmalloc+memset to kzalloc.
> 
> [akpm@osdl.org: fix error-path leak]
> [akpm@osdl.org: cleanups]
> Signed-off-by: Panagiotis Issaris <takis@issaris.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, will push it to 2.6.18 since it is a bug fix
