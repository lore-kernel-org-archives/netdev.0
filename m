From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] atl1c: Fix hardware type check for enabling
 OTP CLK
Date: Sun, 21 Nov 2010 10:07:59 -0800 (PST)
Message-ID: <20101121.100759.59702930.davem@davemloft.net>
References: <1290228936.3818.135.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lrodriguez@atheros.com, Jie.Yang@atheros.com,
	linux-team@atheros.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754881Ab0KUSHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:07:34 -0500
In-Reply-To: <1290228936.3818.135.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 20 Nov 2010 04:55:36 +0000

> Commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
> for Atheros AR8152 and AR8152" added the condition:
> 
>              if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b)
> 
> for enabling OTP CLK, and the condition:
> 
>              if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)
> 
> for disabling OTP CLK.  Since the two previously defined hardware
> types are athr_l1c and athr_l2c, the latter condition appears to be
> the correct one.  Change the former to match.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is compile-tested only.  It looks like the current code may fail to
> read non-volatile settings on the L2C hardware since the EEPROM will not
> be clocked.  Please check this.

This was brought up before, perhaps 4 or 5 months ago, and the maintainers
for this driver just fooled around and never brought this issue to a
meaningful resolution.

So I'm just going to apply your patch instead of waiting another half
year for something to happen.

Thanks Ben.
