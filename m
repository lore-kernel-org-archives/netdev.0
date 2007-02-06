From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 14:09:16 -0800
Message-ID: <1170799756.3535.27.camel@rh4>
References: <200702061536.18800@nienna>
 <20070206.114659.107250775.davem@davemloft.net>
 <45C8EAC4.9020803@cosmosbay.com>
 <20070206.131908.13769204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3805 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965487AbXBFVZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:25:18 -0500
In-Reply-To: <20070206.131908.13769204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-06 at 13:19 -0800, David Miller wrote:

> 
> Because I've seen gcc optimize this properly before (at least on
> sparc64), it means that either:
> 
> 1) There is a GCC bug where the properties of the constants
>    do not propagate.
> 
> 2) GCC really thinks the divide is cheaper (code density vs.
>    cycle count tradeoffs etc.)
> 
> Anyways, we should probably apply your patch in any event.
> 
> Michael, any objections?
> 
No objections.  I will create another patch to convert similar divisions
in other spots.

