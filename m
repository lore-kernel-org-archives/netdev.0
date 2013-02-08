From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Fri, 08 Feb 2013 14:23:09 -0500 (EST)
Message-ID: <20130208.142309.482339537637350318.davem@davemloft.net>
References: <1360244360-2700-1-git-send-email-freddy@asix.com.tw>
	<1360267375.3605.32.camel@bwh-desktop.uk.solarflarecom.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B713F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, freddy@asix.com.tw,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B713F@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 8 Feb 2013 10:23:08 -0000

> It is much better to define constants for the bit values and
> explicitly mask them as required.

Yes, __be32/__le32 along with bit define macros is the only reasonable
way to do this kind of stuff.
