From: David Miller <davem@davemloft.net>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Sun, 08 Nov 2009 22:38:48 -0800 (PST)
Message-ID: <20091108.223848.234795788.davem@davemloft.net>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>
	<20091107.202712.222562359.davem@davemloft.net>
	<1257745762.2609.5.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751724AbZKIGiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 01:38:22 -0500
In-Reply-To: <1257745762.2609.5.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Sun, 08 Nov 2009 21:49:21 -0800

> On Sat, 2009-11-07 at 21:27 -0700, David Miller wrote:
>> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>> Date: Fri, 06 Nov 2009 10:57:21 -0800
>> 
>> > Any comments, thoughts, suggestions, or ideas are welcome.
>> 
>> We can use the existing datastructures and defines used for
>> ETHTOOL_GRX* for new ethtool commands that do filtering.
>> 
>> NIU can filter on these tuples too.
> 
> Are you suggesting to extend the flow hash stuff that is already in
> ethtool (same ioctl)?  If so, that makes sense.  I'll go ahead and get
> some patches together for review.

Not exactly.

Rather, I'm saying to use a new ethtool command, but make use of the
existing flow hash datastructures as much as possible.
