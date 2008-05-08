From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] qla3xxx: Hold RTNL while calling dev_close()
Date: Thu, 08 May 2008 02:53:54 -0700 (PDT)
Message-ID: <20080508.025354.179501881.davem@davemloft.net>
References: <20080506182654.GF2217@solarflare.com>
	<20080506183626.GH2217@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-driver@qlogic.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755272AbYEHJyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 05:54:00 -0400
In-Reply-To: <20080506183626.GH2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 6 May 2008 19:36:26 +0100

> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: David S. Miller <davem@davemloft.net>

Jeff, please pick this up if you haven't already.

Thanks!
