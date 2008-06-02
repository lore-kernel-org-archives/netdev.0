From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Sun, 01 Jun 2008 22:39:38 -0700 (PDT)
Message-ID: <20080601.223938.193701581.davem@davemloft.net>
References: <20080531195702.0b879dd1.billfink@mindspring.com>
	<20080601014620.GG30769@solarflare.com>
	<20080601164614.012fe1f6.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, alan@lxorguk.ukuu.org.uk, jimi@sngx.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750748AbYFBFjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 01:39:42 -0400
In-Reply-To: <20080601164614.012fe1f6.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Sun, 1 Jun 2008 16:46:14 -0400

> Another issue that occurred to me is if multiple people are working
> on troubleshooting a network problem, how do we insure that they all
> get a consistent view of the stats?

Some of them definitely won't get a consistent view if one of them
triggers this undesirable statistic clearing knob.
