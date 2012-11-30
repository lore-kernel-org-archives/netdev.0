From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: RFC: Workaround for problems with lan8710 phy
 auto MDI-X
Date: Fri, 30 Nov 2012 15:00:48 -0500 (EST)
Message-ID: <20121130.150048.112475787724653030.davem@davemloft.net>
References: <alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
	<20121130.122302.1825816242500143123.davem@davemloft.net>
	<1354302880.2640.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, pt@netconsequence.de, otavio@ossystems.com.br,
	javier@dowhile0.org, chohnstaedt@innominate.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354302880.2640.1.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 30 Nov 2012 19:14:40 +0000

> On Fri, 2012-11-30 at 12:23 -0500, David Miller wrote:
>> From: Jiri Kosina <jkosina@suse.cz>
>> Date: Fri, 30 Nov 2012 16:23:30 +0100 (CET)
>> 
>> > Of course it'd be far better if faulty hardware can be autodetected in 
>> > runtime.
>> 
>> That is how this must be handled.
> 
> Well, we also have the recent extension to ETHTOOL_SSET for forcing
> MDI-X on or off.  If it's not possible to detect the faulty hardware
> then the driver can implement this.

Agreed.
