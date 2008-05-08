From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Added ASSERT_RTNL() to dev_open() and dev_close().
Date: Thu, 08 May 2008 02:53:28 -0700 (PDT)
Message-ID: <20080508.025328.58733457.davem@davemloft.net>
References: <20080506182654.GF2217@solarflare.com>
	<20080506183405.GG2217@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754976AbYEHJxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 05:53:34 -0400
In-Reply-To: <20080506183405.GG2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 6 May 2008 19:34:06 +0100

> dev_open() and dev_close() must be called holding the RTNL, since they
> call device functions and netdevice notifiers that are promised the RTNL.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
