From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 12:32:30 -0700 (PDT)
Message-ID: <20101029.123230.226768623.davem@davemloft.net>
References: <1288360820.2092.34.camel@dan>
	<AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
	<AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	drosenberg@vsecurity.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086Ab0J2TcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:32:07 -0400
In-Reply-To: <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 29 Oct 2010 09:21:16 -0700

> NOTE! UNTESTED! It compiles, but I didn't actually boot to check.
> Maybe it has some stupid thinko in it. Also, the patch ended up being
> a bit bigger than it needed to be, because I found some annoying
> whitespace issues in rw_copy_check_uvector (spaces at the beginning of
> lines that had tabs in them) that I couldn't keep myself from not
> fixing.
> 
> Comments?

I just got out of a long dentist appointment, will look at this right
now, thanks!
