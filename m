From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC addresses
Date: Fri, 8 Jan 2010 11:08:48 +1100
Message-ID: <20100108000843.GI2436@verge.net.au>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
 <1262888625.10429.23.camel@Joe-Laptop.home>
 <alpine.LFD.2.00.1001072037170.13474@eddie.linux-mips.org>
 <20100107.140942.135976087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: macro@linux-mips.org, joe@perches.com,
	hartleys@visionengravers.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753980Ab0AHAIv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100107.140942.135976087.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 02:09:42PM -0800, David Miller wrote:
> From: "Maciej W. Rozycki" <macro@linux-mips.org>
> Date: Thu, 7 Jan 2010 20:42:12 +0000 (GMT)
> 
> >  What's the gain?  I'd be rather conservative when taking everybody's 56 
> > bytes for one or two drivers hardly anybody uses.  The format of MAC 
> > addresses is unlikely to change, so I'd say the sources can live with 
> > one or two places where the strings are formatted manually.  Even if the 
> > drivers lose more than these 56 bytes.
> 
> We gain consistency.  You know, the part that's completely bolixed
> right now?
> 
> I'm applying Joe's patch and followon patches to make the driver's
> use the new printf format.

In the vein of this, would it be worth adding some modifier to %i4 to
print addresses for ftp helpers? That is, %u,%u,%u,%u. I think
there are currently two users of that format string after Joe's latest
round of updates.

The users are net/netfilter/ipvs/ip_vs_ftp.c and
net/ipv4/netfilter/nf_nat_ftp.c. Prior to Joe's latest
changes ip_vs_ftp.c used %d,%d,%d,%d.
