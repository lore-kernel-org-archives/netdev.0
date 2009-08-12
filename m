From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: name the network device wlan%d
Date: Wed, 12 Aug 2009 11:31:02 -0500
Message-ID: <1250094662.31650.24.camel@localhost.localdomain>
References: <1250000012-25673-1-git-send-email-daniel@caiaq.de>
	 <20090811143401.GD2684@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@caiaq.de>, libertas-dev@lists.infradead.org,
	Roel Kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org,
	dsd@laptop.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49910 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414AbZHLQb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 12:31:27 -0400
In-Reply-To: <20090811143401.GD2684@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-11 at 10:34 -0400, John W. Linville wrote:
> On Tue, Aug 11, 2009 at 04:13:32PM +0200, Daniel Mack wrote:
> > Devices created by the libertas driver are currently called eth%d. Which
> > is wrong, because the device does not at all have anything to do with
> > Ethernet. And it is also confusing when used on devices with more than
> > one network device.
> > 
> > Fix this by calling it wlan%d.
> > 
> > Signed-off-by: Daniel Mack <daniel@caiaq.de>
> > Cc: Roel Kluin <roel.kluin@gmail.com>
> > Cc: John W. Linville <linville@tuxdriver.com>
> > Cc: netdev@vger.kernel.org
> 
> I'm fine with changing it, but it isn't really wrong either -- it's
> just a name, and afterall in most cases all the user will see is
> ethernet frames.
> 
> Comments from the libertas driver crew?

I don't care either way, it's completely historical.  Most of the
fullmac drivers used 'eth' back when.  Might want to get buy-in from the
OLPC crew since they probably have the most deployed units using
libertas (cc-ed Daniel Drake).

Daniel, is it a problem for you guys if the libertas wifi interface name
went from 'eth' -> 'wlan' ?  Mesh name would be unchanged.

Dan


