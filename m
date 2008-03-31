From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH] [2.6.26 / RFC] e1000: remove PCI Express
 device IDs
Date: Mon, 31 Mar 2008 11:32:12 -0700
Message-ID: <47F12E2C.9010800@intel.com>
References: <20080328174146.11857.94690.stgit@localhost.localdomain>
 <47EDA6CD.50308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:61915 "EHLO
	vms048pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbYCaSjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 14:39:01 -0400
Received: from ahkok-mobl.jf.intel.com ([192.102.209.4])
 by vms048.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JYL003B0YGN9863@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Mon, 31 Mar 2008 13:38:48 -0500 (CDT)
In-reply-to: <47EDA6CD.50308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> We do not want to prolong the situation much longer that e1000
>> and e1000e support these devices at the same time. As a result,
>> take out the bandage that was added for the interim period
>> and remove all the PCI Express device IDs from e1000.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Jeff Garzik <jeff@garzik.org>
>> ---
>>
>>  drivers/net/Kconfig            |    3 ---
>>  drivers/net/e1000/e1000_main.c |   33 ---------------------------------
>>  2 files changed, 0 insertions(+), 36 deletions(-)
> 
> I'm certainly fine with this for 2.6.26.
> 
> Do we need to make a public "move to e1000e" announcement, or were the 
> previous threads sufficient?  :)

I'm OK with that and will write one such thing to lkml+netdev during the next
merge window. ok?

Auke
