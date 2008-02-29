From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 4/4] Don't use seq_release_private where
 inappropriate.
Date: Fri, 29 Feb 2008 11:39:27 -0800 (PST)
Message-ID: <20080229.113927.109042590.davem@davemloft.net>
References: <47C80DA4.9000208@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755861AbYB2Tj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:39:28 -0500
In-Reply-To: <47C80DA4.9000208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 29 Feb 2008 16:50:28 +0300

> Some netfilter code and rxrpc one use seq_open() to open
> a proc file, but seq_release_private to release one.
> 
> This is harmless, but ambiguous.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
