From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Compact some ifdefs in the fib code
Date: Tue, 06 Nov 2007 23:34:40 -0800 (PST)
Message-ID: <20071106.233440.262936518.davem@davemloft.net>
References: <4718BB4A.7020105@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754995AbXKGHes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 02:34:48 -0500
In-Reply-To: <4718BB4A.7020105@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 18:12:26 +0400

> There are places that check for CONFIG_IP_MULTIPLE_TABLES
> twice in the same file, but the internals of these #ifdefs
> can be merged.
> 
> As a side effect - remove one ifdef from inside a function.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
