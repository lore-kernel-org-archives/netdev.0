From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] Move some core sock setup into sk_prot_alloc
Date: Thu, 01 Nov 2007 00:36:46 -0700 (PDT)
Message-ID: <20071101.003646.208870759.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<47288877.10803@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753793AbXKAHgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:36:47 -0400
In-Reply-To: <47288877.10803@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:51:51 +0300

> The security_sk_alloc() and the module_get is a part of the
> object allocations - move it in the proper place.
> 
> Note, that since we do not reset the newly allocated sock
> in the sk_alloc() (memset() is removed with the previous
> patch) we can safely do this.
> 
> Also fix the error path in sk_prot_alloc() - release the security
> context if needed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
