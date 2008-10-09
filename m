From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3] jme: Added half-duplex mode and IPv6
 RSS fix
Date: Wed, 08 Oct 2008 19:51:46 -0700 (PDT)
Message-ID: <20081008.195146.138029640.davem@davemloft.net>
References: <20080915165101.M68109@cooldavid.org>
	<48D27CDA.50501@pobox.com>
	<20081008215205.M37765@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, ethanhsiao@jmicron.com,
	akeem@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750904AbYJICwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 22:52:11 -0400
In-Reply-To: <20081008215205.M37765@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Thu, 9 Oct 2008 05:56:01 +0800

> Dear Jeff, David:
> 
> This patch:
> 
>     1. Set bit 5 of GPREG1 to 1 to enable hardware workaround for half-duplex
>        mode. Which the MAC processor generates CRS/COL by itself instead of
>        receive it from PHY processor.
> 
>     2. Set bit 6 of GPREG1 to 1 to enable hardware workaround that masks the
>        MAC processor working right while calculating IPv6 RSS in 10/100
>        mode.
> 
>     3. Group the workaround codes all together.
> 
>     The patch is also available at:
>     http://cooldavid.org/download/jme.net-next-2.6.20081009.1.patch
> 
>     Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
