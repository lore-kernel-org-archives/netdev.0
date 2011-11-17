From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 20:38:50 -0500 (EST)
Message-ID: <20111116.203850.1548671990526136907.davem@davemloft.net>
References: <1321490078.2709.86.camel@bwh-desktop>
	<20111117011604.GA8683@mcarlson.broadcom.com>
	<1321492892.9114.22.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1KQBix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:38:53 -0500
In-Reply-To: <1321492892.9114.22.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 16 Nov 2011 17:21:32 -0800

> 
> On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
>> > Finally, do these need to be inline?
>> 
>> I don't have a strong preference here either.  Phy code tends to be
>> slower, so there isn't really a strong performance argument.  The
>> implementations don't seem to be so large to argue against it though.
>> Would you prefer they not be inlined?
>> 
> 
> Since we are defining these in .h file, they need to be inline, right?
> Otherwise multiple source files including the same .h file will have
> conflict.

Yes, if you keep them in the header you have to keep them inline.

Ben, by suggesting to not inline them, is implicitly saying to put
them out in a seperate *.c file somewhere, perhaps net/core/ethtool.c
or similar.  With appropriate EXPORT_SYMBOL() added.
