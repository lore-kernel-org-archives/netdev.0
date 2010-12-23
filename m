From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: prevent integer underflow in IRLMP_ENUMDEVICES
Date: Thu, 23 Dec 2010 10:09:20 -0800 (PST)
Message-ID: <20101223.100920.48494288.davem@davemloft.net>
References: <1293062307.9820.331.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752286Ab0LWSIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 13:08:50 -0500
In-Reply-To: <1293062307.9820.331.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 22 Dec 2010 18:58:27 -0500

> If the user-provided len is less than the expected offset, the
> IRLMP_ENUMDEVICES getsockopt will do a copy_to_user() with a very large
> size value.  While this isn't be a security issue on x86 because it will
> get caught by the access_ok() check, it may leak large amounts of kernel
> heap on other architectures.  In any event, this patch fixes it.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

Applied, thanks.
