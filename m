From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Mon, 26 Dec 2011 23:54:39 -0500
Message-ID: <4EF94F8F.7060506@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <4EF6803C.9060203@gentoo.org> <20111226.151713.2002746283994460284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:60333 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751123Ab1L0EzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 23:55:02 -0500
In-Reply-To: <20111226.151713.2002746283994460284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/26/2011 15:17, David Miller wrote:

> From: Joshua Kinard <kumba@gentoo.org>
> Date: Sat, 24 Dec 2011 20:45:32 -0500
> 
>> SGI IP32 (O2)'s ethernet driver (meth) lacks meth_set_rx_mode, which
>> prevents IPv6 from working completely because any ICMPv6 neighbor
>> solicitation requests aren't picked up by the driver.  So the machine can
>> ping out and connect to other systems, but other systems will have a very
>> hard time connecting to the O2.
>>
>> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
> 
> Lots of completely unrelated changes here, the IRQ name string has
> nothing to do with specifically fixing the ICMPv6 neighbour discovery
> bug.
> 
> Do not mix changes like this, one change per patch please, thanks.


Noted.  I dropped the name change patch and minimized the changes to the
mace registers to just the two registers needed for this specific case.
I'll send two separate patches for the remaining registers and the name bit
to just linux-mips later on.  Patch to follow.

Thanks,

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
