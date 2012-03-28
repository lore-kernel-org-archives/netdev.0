From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Wed, 28 Mar 2012 16:54:17 -0400 (EDT)
Message-ID: <20120328.165417.1083579824641543055.davem@davemloft.net>
References: <20120326231017.GA30684@kroah.com>
	<20120326.191237.2192763107267474232.davem@davemloft.net>
	<1332957900.2624.38.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, haiyangz@microsoft.com,
	netdev@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332957900.2624.38.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Mar 2012 19:05:00 +0100

> On Mon, 2012-03-26 at 19:12 -0400, David Miller wrote:
>> From: Greg KH <gregkh@linuxfoundation.org>
>> Date: Mon, 26 Mar 2012 16:10:17 -0700
>> 
>> > David, please do NOT apply this as-is.
>> 
>> BTW, ethtool had controls exactly for stuff like this.
> 
> Not sure what you're thinking of...?  We have pause frame control but I
> don't think that's applicable.

As I understand this, this situation is really about interrupt flow
control, and for that we have the interrupt moderation ethtool
settings.
