From: David Miller <davem@davemloft.net>
Subject: Re: [patch] r8169: fix crash when large packets are received
Date: Tue, 09 Jun 2009 03:54:35 -0700 (PDT)
Message-ID: <20090609.035435.193703945.davem@davemloft.net>
References: <1244511638.30733.41.camel@localhost.localdomain>
	<20090608.195709.158667574.davem@davemloft.net>
	<4A2E2456.4020703@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonathan@jonmasters.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com, stable@kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755046AbZFIKyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 06:54:33 -0400
In-Reply-To: <4A2E2456.4020703@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Tue, 09 Jun 2009 12:59:02 +0400

> David Miller wrote:
>> From: Jon Masters <jonathan@jonmasters.org>
>> Date: Mon, 08 Jun 2009 21:40:38 -0400
>> 
>>> CC -stable team - remote DoS with this hardware present.
>> "remote", if on the same physical subnet, otherwise easily protectable
>> if not impossible to trigger
> 
> "remote" as "from outside of the host in question".
> But still, this is definitely worth fixing.

Of course, just wanted to make sure the true nature of the problem
was explicit.
