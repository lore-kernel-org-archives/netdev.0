From: Roger While <simrw@sim-basis.de>
Subject: Re. Please pull 'upstream' branch of wireless-2.6
Date: Thu, 09 Nov 2006 09:24:25 +0100
Message-ID: <6.1.1.1.2.20061109092037.02b2ee80@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout11.sul.t-online.com ([194.25.134.85]:1465 "EHLO
	mailout11.sul.t-online.com") by vger.kernel.org with ESMTP
	id S1754761AbWKIIZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 03:25:01 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John wrote :
>Yeah, looks like I was a bit overzealous on the warning squelch...
>
>I'll cook-up a new patch that doesn't error-out.

I hope you do not bloat the kernel with meaningless warning messages.
Something simple like the following will do.

         /* enable MWI */
         /* Shut up the must_check tests - We don't care if this does not 
succeed */
         if (pci_set_mwi(pdev))
                 rvalue = 0;


Roger While


