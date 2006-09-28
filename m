From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:16:49 -0700 (PDT)
Message-ID: <20060928.151649.71167157.davem@davemloft.net>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
	<1159474625.3741.6.camel@rh4>
	<Pine.LNX.4.64.0609281632200.28620@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, shemminger@osdl.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6614
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030383AbWI1WQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:16:46 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0609281632200.28620@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 28 Sep 2006 16:32:38 -0400 (EDT)

> On Thu, 28 Sep 2006, Michael Chan wrote:
> 
> > I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
> > Dumping 64K worth of registers and blinking the LEDs should be
> > restricted.
> 
> Out of curiosity -- why?

Reading some registers might have side effects, that's one thing.

Secondarily, looping over reading all of the registers of the chip
might kill performance since the IO accesses compete with the
normal packet sending/receiving operations.
