From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 20/50] smsc911x: use dev_hw_addr_random() instead of
 random_ether_addr()
Date: Thu, 9 Feb 2012 11:28:48 +0000
Message-ID: <20120209112848.GA2590@sirena.org.uk>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
 <1328735457-29986-21-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328735457-29986-21-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2012 at 10:10:27PM +0100, Danny Kukawka wrote:

> +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> +		dev->addr_assign_type ^= NET_ADDR_RANDOM;

It would be clearer to just write

		dev->addr_assign_type &= ~NET_ADDR_RANDOM;

to clear the bit - the ^ takes more thinking.
