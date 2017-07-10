From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/2 net] ptp: fix error codes in ptp_clock_register()
Date: Mon, 10 Jul 2017 13:29:20 +0300
Message-ID: <20170710102920.gav646pmteijfxfl@mwanda>
References: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
 <20170710092103.vnanagwpimk43zoz@localhost.localdomain>
 <20170710093816.wz5uiqoyilgxmgh3@mwanda>
 <20170710094806.lsrua5iqnmnntc5m@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ganesh Goudar <ganeshgr@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41755 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752658AbdGJK3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 06:29:43 -0400
Content-Disposition: inline
In-Reply-To: <20170710094806.lsrua5iqnmnntc5m@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 11:48:06AM +0200, Richard Cochran wrote:
> On Mon, Jul 10, 2017 at 12:38:16PM +0300, Dan Carpenter wrote:
> > There were two buggy commits so I chose the ealier one.  The other buggy
> 
> No, you are mistaken.  In the original patch, NULL or PTR_ERR were
> returned on error, and that was not a bug.
> 

The "goto no_pps" was a bug you introduced.

But I feel like you're being rude, so I'm not going to resend these
patches.  Please fix them yourself.

regards,
dan carpenter
