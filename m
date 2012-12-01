From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: sky2: Correct mistakenly switched read/write sequence
Date: Sat, 1 Dec 2012 21:06:11 +0100
Message-ID: <20121201200611.GA9527@neptun>
References: <20121201124239.GB3914@neptun>
 <20121201.122701.2065141028797970034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LinoSanfilippo@gmx.de, shemminger@vyatta.com, mlindner@marvell.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:56536 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752297Ab2LAUGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 15:06:16 -0500
Content-Disposition: inline
In-Reply-To: <20121201.122701.2065141028797970034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2012 at 12:27:01PM -0500, David Miller wrote:
> 
> > In sky2_all_down() the order of the read()/write() access to B0_IMSK seems to
> > be mistakenly switched. The original intention was obviously to avoid PCI write
> > posting.
> > This patch fixes the order.
> > 
> > Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> 
> I would say that no such intention exists at all.
> 
> The read is there because a long time ago the result as used
> to compute an 'imask' variable.
> 
> Please see commit:
> 
> commit d72ff8fa7f8b344382963721f842256825c4660b

I see. Indeed I was not aware of the history that led to the recent code, so
thanks for pointing that out.

However, since Stephen thinks the patch is useful nevertheless:
@Stephen please feel free to adjust the commit message as you think would make 
the most sense.

Regards,
Lino
