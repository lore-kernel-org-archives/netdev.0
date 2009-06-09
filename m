From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bonding-devel] BUG: bonding module can only be loaded once
Date: Wed, 10 Jun 2009 00:14:08 +0200
Message-ID: <4A2EDEB0.2080006@trash.net>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net> <4752.1244564082@death.nxdomain.ibm.com> <4A2E8D62.6090004@trash.net> <13521.1244568251@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bonding-devel@lists.sf.net,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40635 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbZFIWOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 18:14:08 -0400
In-Reply-To: <13521.1244568251@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> I'd expect its not the distros, but rather the applicances which might
>> still be using this. I know a vendor I used to work for a couple of
>> years ago just recently made the switch from 2.6.16 to a current kernel,
>> and I'd expect that they are still using this (I can find out tommorrow
>> if you want to know for sure). Vyatta likewise, I guess.
> 
> 	Yes, I'd like to know for sure; thanks.

I'll let you know.

>>> 	If nobody has any heartburn at dropping support for multiple
>>> bonding instances on old distros, I'm as happy as anybody to remove all
>>> of the multiple load logic from bonding.  There's been plenty of time
>>> for transitioning from "multiple load" to sysfs.
>> In my opinion it would need a feature-removal-schedule announcement.
> 
> 	Yah, probably.  The multiple load stuff was working fine as of,
> oh, a year or two ago, so I wasn't worried so much about getting rid of
> it.  If it's causing problems, though, it's time for it to go (or be
> scheduled to go in the not too distant future).  Can't keep driving that
> Ford Pinto forever.

Well, if it has been broken for long enough, maybe we don't need
a feature-removal-schedule warning.
