From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
 ISDN
Date: Sun, 07 Oct 2007 08:24:45 -0400
Message-ID: <4708D00D.8030307@garzik.org>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59227 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515AbXJGMYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 08:24:55 -0400
In-Reply-To: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Mohr wrote:
> I intend to still try to get it up and running with 2.6.23-rc8-mm2 today
> (with some workarounds hopefully, maybe even disabling ISDN completely)...
> 
> The last running kernel (I didn't have newer ones in between), up for some 110
> days was 2.6.19-cks2 (IOW, I cannot quite say that
> "this is an important regression, it has been broken very recently").


It definitely looks like ISDN is somehow to blame.  Any chance you could 
try git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.24.git ?

That would help narrow down the problem to a very-large set of 
networking changes pending for 2.6.24.

If you can isolate it to net-2.6.24, it should be easily bisect-able 
from there, if you have the patience :)

	Jeff


