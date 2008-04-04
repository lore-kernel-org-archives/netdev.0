From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [E1000-devel] [PATCH] [2.6.26 / RFC] e1000: remove PCI Express
 device IDs
Date: Fri, 04 Apr 2008 04:08:31 -0400
Message-ID: <47F5E1FF.4030005@garzik.org>
References: <20080328174146.11857.94690.stgit@localhost.localdomain> <47EDA6CD.50308@garzik.org> <47F12E2C.9010800@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58909 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbYDDIIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 04:08:34 -0400
In-Reply-To: <47F12E2C.9010800@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Auke Kok wrote:
>>> We do not want to prolong the situation much longer that e1000
>>> and e1000e support these devices at the same time. As a result,
>>> take out the bandage that was added for the interim period
>>> and remove all the PCI Express device IDs from e1000.
>>>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>>> Cc: Jeff Garzik <jeff@garzik.org>
>>> ---
>>>
>>>  drivers/net/Kconfig            |    3 ---
>>>  drivers/net/e1000/e1000_main.c |   33 ---------------------------------
>>>  2 files changed, 0 insertions(+), 36 deletions(-)
>> I'm certainly fine with this for 2.6.26.
>>
>> Do we need to make a public "move to e1000e" announcement, or were the 
>> previous threads sufficient?  :)
> 
> I'm OK with that and will write one such thing to lkml+netdev during the next
> merge window. ok?

I'd say write one sooner rather than later... :)  "this is coming"
