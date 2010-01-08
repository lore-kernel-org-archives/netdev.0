From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Fri, 08 Jan 2010 13:21:07 -0800 (PST)
Message-ID: <20100108.132107.38069748.davem@davemloft.net>
References: <20100105.163911.10233438.davem@davemloft.net>
	<20100108124033.GA28782@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52168
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754086Ab0AHVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 16:20:59 -0500
In-Reply-To: <20100108124033.GA28782@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 8 Jan 2010 07:40:33 -0500

> Dave, sorry about this, but it looks like we can scrap this, I just
> looked at the initial tcpdump this was reported in, and apparently
> w2k doesn't compute the checksum properly on these old style
> keepalives.

Thanks for the update.  Nothing to be sorry about, this is actually a
relief and we learned a lot about keepalives and zero-window probes in
the process :-)
