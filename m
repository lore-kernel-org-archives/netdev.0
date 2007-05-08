From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Tue, 8 May 2007 13:40:01 +0200
Message-ID: <20070508114001.GC32055@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967356AbXEHLkG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m3vef5biob.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 02:07:16AM +0200, Krzysztof Halasa wrote:

> + * Ethernet port config (0x00 is not present on IXP42X):
> + *
> + * logical port		0x00		0x10		0x20
> + * NPE			0 (NPE-A)	1 (NPE-B)	2 (NPE-C)
> + * physical PortId	2		0		1
> + * TX queue		23		24		25
> + * RX-free queue	26		27		28
> + * TX-done queue is always 31, RX queue is configurable

(Note that this assignment depends on the firmware, and different
firmware versions use different queues -- you might want to add a
note about which firmware version this holds for.)
