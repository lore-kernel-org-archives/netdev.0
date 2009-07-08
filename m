From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.1] davinci_emac: fix kernel oops when changing MAC
 address while interface is down
Date: Tue, 07 Jul 2009 19:14:59 -0700 (PDT)
Message-ID: <20090707.191459.34042463.davem@davemloft.net>
References: <1246947026.3714.9.camel@desktop-002>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source@linux.davincidsp.com,
	netdev@vger.kernel.org
To: pablo.bitton@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756989AbZGHCO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:14:56 -0400
In-Reply-To: <1246947026.3714.9.camel@desktop-002>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Bitton <pablo.bitton@gmail.com>
Date: Tue, 07 Jul 2009 09:10:26 +0300

> Check that network interface is running before changing its MAC address.
> Otherwise, rxch is accessed when it's NULL - causing a kernel oops.
> Moreover, check that the new MAC address is valid.
> 
> Signed-off-by: Pablo Bitton <pablo.bitton@gmail.com>
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> Tested-by: Chaithrika U S <chaithrika@ti.com>
> [tested on DM6467 EVM]

Applied to net-2.6, thanks.
