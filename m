From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin
 EMAC interrupt may not be shared
Date: Fri, 29 May 2009 04:14:35 -0700 (PDT)
Message-ID: <20090529.041435.163819214.davem@davemloft.net>
References: <8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com>
	<20090529.035344.92579416.davem@davemloft.net>
	<8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Michael.Hennerich@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756140AbZE2LOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:14:36 -0400
In-Reply-To: <8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Date: Fri, 29 May 2009 12:12:49 +0100

> Our handler isn't prepared to handle such fake interrupts.
> So two options:
> 1) Set the proper IRQF flags.
> 2) Fix the ISR to handle spurious interrupts.
> 
> This patch chose option 1) 

And to go back to my initial reply, I'm saying to do the
"right thing" and go with #2 if you can :-)
