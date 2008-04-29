From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Tue, 29 Apr 2008 15:20:14 -0700 (PDT)
Message-ID: <20080429.152014.00555445.davem@davemloft.net>
References: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: miika@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755867AbYD2WUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 18:20:16 -0400
In-Reply-To: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miika Komu <miika@iki.fi>
Date: Wed, 30 Apr 2008 00:07:56 +0300 (EEST)

> Host Identity Protocol (HIP, RFC5201, RFC4423) and Site Multihoming for 
> IPv6 (SHIM6, draft-ietf-shim6-proto-10) define new APIs in the URLs below. 
> This patch exports some IPv6 symbols to help in initial IETF 
> experimentation with external kernel modules for HIP and SHIM6 socket 
> handlers. The SHIM6 and HIP socket handlers are built on top of IPv6 
> socket handlers.
> http://www.ietf.org/internet-drafts/draft-ietf-hip-native-api-04.txt
> http://www.ietf.org/internet-drafts/draft-ietf-shim6-multihome-shim-api-05.txt
> 
> 
> Signed-off-by: Miika Komu <miika@iki.fi>

This is not how we do things.

When the HIP implementation is submitted for inclusion, the module
exports can be added, not before.
