From: Bas Vermeulen <bvermeul@blackstar.nl>
Subject: Re: Wireless: One small step towards a more perfect union...?
Date: Wed, 11 Jan 2006 14:19:16 +0100
Message-ID: <1136985556.5050.29.camel@laptop.blackstar.nl>
References: <20060106042218.GA18974@havoc.gtf.org>
	 <20060111020534.GA22285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751540AbWAKNT2@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060111020534.GA22285@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-10 at 21:05 -0500, John W. Linville wrote:
> If you are the maintainer of an out-of-tree driver or other component
> (e.g. softmac), please let me hear from you (publicly or privately).
> I want to be sure to identify all the major stakeholders.  I would
> also like to hear your plans for getting your code into the tree... :-)

I'm the author of a driver for the No Wires Needed card family.
It's a bit of an odd-man-out in the wireless devices world, as all the
wireless management is being done in firmware. Packets are read/sent
through a 16550 type interface as ethernet packets, and management
packets to control the card are sent in a similar way (but with a
different packet type). I inject management packets into the network
queue with dev_queue_xmit(), meaning the network queue takes care of the
correct locking.

I'd be interested in getting it integrated into mainline, although I'll
have to devote some time to get the pcmcia handling up to scratch, as
well as update to the latest wireless extensions (or any of the other
management utensils).

Let me know if you are interested in a patch, and I'll see what I can do
in the near future.

-- 
Bas Vermeulen <bvermeul@blackstar.nl>
