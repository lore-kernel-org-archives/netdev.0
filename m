From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] libertas: name the network device wlan%d
Date: Tue, 11 Aug 2009 10:34:01 -0400
Message-ID: <20090811143401.GD2684@tuxdriver.com>
References: <1250000012-25673-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: libertas-dev@lists.infradead.org,
	Roel Kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35496 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbZHKQqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 12:46:11 -0400
Content-Disposition: inline
In-Reply-To: <1250000012-25673-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2009 at 04:13:32PM +0200, Daniel Mack wrote:
> Devices created by the libertas driver are currently called eth%d. Which
> is wrong, because the device does not at all have anything to do with
> Ethernet. And it is also confusing when used on devices with more than
> one network device.
> 
> Fix this by calling it wlan%d.
> 
> Signed-off-by: Daniel Mack <daniel@caiaq.de>
> Cc: Roel Kluin <roel.kluin@gmail.com>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: netdev@vger.kernel.org

I'm fine with changing it, but it isn't really wrong either -- it's
just a name, and afterall in most cases all the user will see is
ethernet frames.

Comments from the libertas driver crew?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
