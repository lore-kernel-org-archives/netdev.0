From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 19 Sep 2006 12:45:53 -0400
Message-ID: <45101EC1.7040407@garzik.org>
References: <E1GPflG-0000n7-2o@lucciola> <Pine.LNX.4.64N.0609191441260.24069@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amy Fong <amy.fong@windriver.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25780 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030254AbWISQp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 12:45:58 -0400
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0609191441260.24069@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
> On Tue, 19 Sep 2006, Amy Fong wrote:
> 
>>> And... where are the users of this phy driver?
> [...]
>> This phy driver is used by the WRS's sbc8560 (bcm5421s) and sbc843x 
>> (bcm5461s) via the gianfar driver.
> 
>  And sb1250-mac.c would be happy to use it too.

"would be happy to" != "is using".   I don't want to add a phy driver 
until there are already active users in the kernel.

	Jeff



