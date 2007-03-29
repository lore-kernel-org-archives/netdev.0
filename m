From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 17:42:54 -0600
Message-ID: <460C4EFE.6030505@nortel.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:47960 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934363AbXC3AEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 20:04:22 -0400
In-Reply-To: <4074.1175207458@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:

> 	2.6.10 is pretty old, and there have been a number of fixes to
> the bonding ARP monitor since then, so it may be that it is simply
> misbehaving (presuming that you're running the 2.6.10 bonding driver).
> Are you in a position to test against a more recent kernel (and/or
> bonding driver)?  Does the miimon misbehave in a similar fashion?

Testing a more recent kernel is problematic.  A new bonding driver could 
be possible, assuming the code hasn't changed too much.

I just did another experiment.  Normally we boot via eth4 (which then 
becomes part of the bond  with eth5 at init time).  If I boot via eth6 
instead, it appears as though the problem doesn't show up.

Chris
