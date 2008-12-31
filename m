From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: use consistent types
Date: Tue, 30 Dec 2008 21:49:59 -0800 (PST)
Message-ID: <20081230.214959.141224132.davem@davemloft.net>
References: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, santil@us.ibm.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51268
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbYLaFt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 00:49:57 -0500
In-Reply-To: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 Dec 2008 14:02:25 +1100

> These variables are only used with an interface involving "unsigned
> long" and the macros are only used with these variables.  This change
> will prevent some warnings when we change u64 to "unsigned long long".
> 
> This code is only built for 64bit powerpc, so the transformation is
> really a noop.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

I'd prefer if the types were to remain 32-bit portable.

Doing things like this is just a problem waiting to happen,
either for the first person who actually finds a need and
a way to use this driver on 32-bit or the person who cut and
pastes this code into their driver which should work on both
32-bit and 64-bit.

Patch not applied.
