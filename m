From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 09/12] net: mediatek: increase watchdog_timeo
Date: Sun, 5 Jun 2016 16:56:32 +0200
Message-ID: <20160605145632.GI12165@lunn.ch>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
 <1465108385-38286-10-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465108385-38286-10-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 05, 2016 at 08:33:02AM +0200, John Crispin wrote:
> During stress testing, after reducing the threshold value, we have seen
> TX timeouts that were caused by the watchdog_timeo value being too low.
> Increase the value to 5 * HZ which is a value commonly used by many other
> drivers.

I've never studied what watchdog_timeo actually means. Does it mean a
transmit has not completed in that amount of time? Would this imply
you have 5 seconds worth of packets in your transmit queue? Do you
know what the driver is doing during this 5 seconds?

Thanks
    Andrew
