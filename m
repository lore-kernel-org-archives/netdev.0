From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken for POWER architecture?
Date: Wed, 12 Sep 2007 06:27:32 -0700 (PDT)
Message-ID: <20070912.062732.68054135.davem@davemloft.net>
References: <200709071137.02801.ossthema@de.ibm.com>
	<20070912.055004.88490155.davem@davemloft.net>
	<OF2D6ED296.BDB04FBF-ONC1257354.00473703-C1257354.0048406C@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: THEMANN@de.ibm.com, netdev@vger.kernel.org,
	ossthema@linux.vnet.ibm.com, shemminger@linux-foundation.org,
	ARNDB@de.ibm.com, pmac@au1.ibm.com, ellerman@au1.ibm.com,
	linuxppc-dev@ozlabs.org
To: RAISCH@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36243
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754988AbXILN2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:28:41 -0400
In-Reply-To: <OF2D6ED296.BDB04FBF-ONC1257354.00473703-C1257354.0048406C@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Raisch <RAISCH@de.ibm.com>
Date: Wed, 12 Sep 2007 15:10:08 +0200

> This is definitely not something we can change in the HEA device driver
> alone.

And it shouldn't be, x86 implements the policy in irq balance
daemon, powerpc should do it wherever it would be appropriate
there.

> Paul, Michael, Arndt, what is your opinion here?

I'm all ears too :)
