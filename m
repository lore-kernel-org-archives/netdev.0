From: Stefan Lippers-Hollmann <s.l-h@gmx.de>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Sun, 15 Nov 2015 19:25:47 +0100
Message-ID: <20151115192547.3fd1b3cc@mir>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	johannes@sipsolutions.net
To: Dave Young <dyoung@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On 2015-11-15, Dave Young wrote:
> cfg80211 module prints a lot of messages like below. Actually printing
> once is acceptable but sometimes it will print again and again, it looks
> very annoying. It is better to change these detail messages to debugging
> only.

It is a lot of info, easily repeated 3 times on boot, but it's also the
only real chance to determine why you ended up with the regulatory 
domain settings you got, rather than just the values itself. Given that
a lot (most?) of officially shipping wireless devices are misconfigured
(wrong EEPROM regdom settings for the region they're sold in) and 
considering that the limits can even change at runtime (IEEE 802.11d), 
it is imho quite important not just to be able what the current 
restrictions (iw reg get) are, but also why the kernel settled on those.

Regards
	Stefan Lippers-Hollmann
