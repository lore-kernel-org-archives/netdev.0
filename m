From: Adam Kropelin <akropel1@rochester.rr.com>
Subject: Re: [PATCH 2/2] pcnet32: PHY selection support
Date: Fri, 17 Feb 2006 13:49:38 -0500
Message-ID: <20060217134938.B24429@mail.kroptech.com>
References: <43F5F672.9080904@bfh.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tsbogend@alpha.franken.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751148AbWBQR5U@vger.kernel.org>
To: philippe.seewer@bfh.ch
Content-Disposition: inline
In-Reply-To: <43F5F672.9080904@bfh.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seewer Philippe wrote:
> Most AMD pcnet chips support up to 32 external PHYs. This patch
> introduces basic PHY selection/switching support, by adding two
> new module parameters:
> -maxphy: how many PHYs the card supports
> -usephy: which phy to use instead of eeprom default
> 
> Maxphy is necessary in order to check the range of usephy and may
> be overriden inside the module.

It seems a bit pointless for the range check of a user-supplied value to
be driven by another user-supplied value.

> If only maxphy is present I've implemented an algorithm which checks
> the link state on all PHYs and uses the one that has a link.

Knowing how many PHYs to scan is potentially useful, but how about
determining that at runtime? Missing PHYs should be detectable with a
timeout or similar. Too risky?

--Adam
