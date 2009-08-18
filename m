From: David Miller <davem@davemloft.net>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 18:27:54 -0700 (PDT)
Message-ID: <20090817.182754.50348941.davem@davemloft.net>
References: <4A89DB15.6060101@am.sony.com>
	<20090817.180323.253692704.davem@davemloft.net>
	<4A8A02CA.7040305@am.sony.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: tim.bird@am.sony.com
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <4A8A02CA.7040305@am.sony.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Bird <tim.bird@am.sony.com>
Date: Mon, 17 Aug 2009 18:24:26 -0700

> David Miller wrote:
>> I have card/switch combinations that take up to 10 seconds to
>> negotiate a proper link.
> 
> What types of delays are these timeouts supposed to
> cover?

The problem is that if you don't first give at least some time for the
link to come up, the remaining time it takes the link to come up will
end up chewing into the actual bootp/dhcp protocol timeouts.  And
that's what we're trying to avoid.
