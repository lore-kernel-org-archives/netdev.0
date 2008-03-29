From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [2.6.26 / RFC] e1000: remove PCI Express device IDs
Date: Fri, 28 Mar 2008 22:17:49 -0400
Message-ID: <47EDA6CD.50308@garzik.org>
References: <20080328174146.11857.94690.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	e1000-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47950 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753349AbYC2CRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:17:50 -0400
In-Reply-To: <20080328174146.11857.94690.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> We do not want to prolong the situation much longer that e1000
> and e1000e support these devices at the same time. As a result,
> take out the bandage that was added for the interim period
> and remove all the PCI Express device IDs from e1000.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> ---
> 
>  drivers/net/Kconfig            |    3 ---
>  drivers/net/e1000/e1000_main.c |   33 ---------------------------------
>  2 files changed, 0 insertions(+), 36 deletions(-)

I'm certainly fine with this for 2.6.26.

Do we need to make a public "move to e1000e" announcement, or were the 
previous threads sufficient?  :)

	Jeff



