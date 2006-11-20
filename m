From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH 2/4] atl1: Header files for Attansic L1 driver
Date: Mon, 20 Nov 2006 12:02:12 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0611201200190.28860@yvahk01.tjqt.qr>
References: <20061119203006.GC29736@osprey.hogchain.net>
 <Pine.LNX.4.61.0611192233270.6324@yvahk01.tjqt.qr> <456144C1.8040809@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	shemminger@osdl.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailer.gwdg.de ([134.76.10.24]:27564 "EHLO emailer.gwdg.de")
	by vger.kernel.org with ESMTP id S1756748AbWKTLRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 06:17:37 -0500
To: Chris Snook <csnook@redhat.com>
In-Reply-To: <456144C1.8040809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 20 2006 01:01, Chris Snook wrote:
> Jan Engelhardt wrote:
>> > +#define AT_READ_REG_ARRAY(a, reg, offset) ( \
>> > +	readl(((a)->hw_addr + reg) + ((offset) << 2)))
>> 
>> Possibly similarly.
>
> Yeah, we'll inline these as well.  Would you say that level of cosmetic
> cleanliness is required for merging, or should we focus solely on the
> functional issues for now?

Required? No I do not think so, there is worse code than this. (Don't
take that as an excuse to write bad code! :-)
It's just that it's easier to read if there are less parentheses.
These defines are a good example of border (define vs inline) cases.


	-`J'
-- 
