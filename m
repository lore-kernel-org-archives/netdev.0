From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Scaling problem with a lot of AF_PACKET sockets on different
 interfaces
Date: Fri, 07 Jun 2013 07:30:20 -0700
Message-ID: <1370615420.24311.425.camel@edumazet-glaptop>
References: <51B1CA50.30702@telenet.dn.ua>
	 <1370608871.5854.64.camel@marge.simpson.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B727B@saturn3.aculab.com>
	 <1370613289.24311.419.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B727D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <bitbucket@online.de>,
	"Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B727D@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 15:09 +0100, David Laight wrote:
> > > Looks like the ptype_base[] should be per 'dev'?
> > > Or just put entries where ptype->dev != null_or_dev on a per-interface
> > > list and do two searches?
> > 
> > Yes, but then we would have two searches instead of one in fast path.
> 
> Usually it would be empty - so the search would be very quick!

quick + quick + quick + quick + quick == not so quick ;)

Plus adding another code for /proc/net/packet

Plus adding the xmit side (AF_PACKET captures receive and xmit)
