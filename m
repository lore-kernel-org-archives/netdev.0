From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 2/5] sis900 printk and stack usage audit
Date: Sun, 12 Dec 2004 09:19:04 +0100
Message-ID: <20041212081904.GB3084@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110426.GC31707@picchio.gall.it> <41BB45D6.2090608@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniele Venzano <webvenza@libero.it>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41BB45D6.2090608@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 11, 2004 at 02:09:10PM -0500, Jeff Garzik wrote:
> >@@ -568,14 +580,15 @@
> > 
> > 		for (i = 0; mii_chip_table[i].phy_id1; i++)
> > 			if ((mii_phy->phy_id0 == mii_chip_table[i].phy_id0 ) 
> > 			&&
> >-			    ((mii_phy->phy_id1 & 0xFFF0) == 
> >mii_chip_table[i].phy_id1)){
> >+			    ((mii_phy->phy_id1 & 0xFFF0) == 
> >mii_chip_table[i].phy_id1))
> >+			{
> 
> CodingStyle:  the brace following an 'if' does not exist on a line by 
> itself.

The line is too long, and it is difficult to see where the if block
begins, I know it is an exception to the Golden Rules, but I thought a
line wasted in code readbility was well wasted.
However I don't think it really matters, will drop it.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
