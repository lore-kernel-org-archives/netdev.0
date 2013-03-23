From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] bnx2x: fix assignment of signed expression to unsigned
 variable
Date: Sun, 24 Mar 2013 00:19:57 +0300
Message-ID: <20130323211957.GC9138@mwanda>
References: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
 <20130323195454.GB9138@mwanda>
 <20130323204511.GA18813@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Kumar amit mehta <gmate.amit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41394 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab3CWVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 17:20:09 -0400
Content-Disposition: inline
In-Reply-To: <20130323204511.GA18813@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 23, 2013 at 01:45:11PM -0700, Kumar amit mehta wrote:
> On Sat, Mar 23, 2013 at 10:56:47PM +0300, Dan Carpenter wrote:
> >
> > The fix for this is more involved.  The function prototype should
> > be changed to return an int.  The caller should be updated to check
> > for errors.
> >
> I wonder, why these callbacks are restricting the lower layers to return
> only unsigned values, However Updating the prototype doesn't seem a good idea as
> then it would require changes in various existing drivers.

Yes.  Everything will need to be updated.  I've known this code is
buggy for years but I've never tried patching it because I'm very
lazy.  :)

But actually it's only three drivers I think: bnx2x, ixgbe, and
mlx4.   I suspect that most of the functions always return zero and
won't need to be modified.

regards,
dan carpenter
