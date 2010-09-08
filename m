From: David Miller <davem@davemloft.net>
Subject: Re: Is via-velocity broken in 2.6.34?
Date: Wed, 08 Sep 2010 08:30:22 -0700 (PDT)
Message-ID: <20100908.083022.189687100.davem@davemloft.net>
References: <AANLkTin6RcDPFWpG4YBRF4O-8nrsA6e77K=knBA-uyf9@mail.gmail.com>
	<20100907.172434.28821101.davem@davemloft.net>
	<AANLkTi=kbonQ11mLpkd4EnSr3ch8yDssnjaUsgw_tVw9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: matt.causey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126Ab0IHPaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:30:04 -0400
In-Reply-To: <AANLkTi=kbonQ11mLpkd4EnSr3ch8yDssnjaUsgw_tVw9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Causey <matt.causey@gmail.com>
Date: Wed, 8 Sep 2010 08:27:19 -0700

> config VIA_VELOCITY
>         tristate "VIA Velocity support"
>         depends on PCI && PM && ACPI
> 
> since today it's only depending on pci.
> 
> If this is the right thing to do I can submit a patch .  Apologies
> again for the red herring.  :-)

Needing ACPI for proper functioning of a moden x86 system
is no surprise, and isn't a VIA specific issue :-)
