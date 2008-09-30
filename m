From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iucv: Fix mismerge again.
Date: Tue, 30 Sep 2008 03:06:55 -0700 (PDT)
Message-ID: <20080930.030655.205785115.davem@davemloft.net>
References: <20080925110907.GA22433@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: frank.blaschka@de.ibm.com, braunu@de.ibm.com,
	peter.oberparleiter@de.ibm.com, schwidefsky@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752559AbYI3KHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 06:07:07 -0400
In-Reply-To: <20080925110907.GA22433@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Thu, 25 Sep 2008 13:09:07 +0200

> iucv: Fix mismerge again.
 ...
> fb65a7c091529bfffb1262515252c0d0f6241c5c ("iucv: Fix bad merging.") fixed
> a merge error, but in a wrong way. We now end up with the bug below.
> This patch corrects the mismerge like it was intended.
> 
> BUG: scheduling while atomic: swapper/1/0x00000000
 ...
> initcall netiucv_init+0x0/0x2c8 returned with preemption imbalance
> 
> Cc: Peter Oberparleiter <peter.oberparleiter@de.ibm.com>
> Cc: Ursula Braun <braunu@de.ibm.com>
> Cc: Frank Blaschka <frank.blaschka@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied to net-2.6, thanks.
