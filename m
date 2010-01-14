From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netxen: endianness fixes
Date: Thu, 14 Jan 2010 03:08:54 -0800 (PST)
Message-ID: <20100114.030854.52825026.davem@davemloft.net>
References: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43661
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756137Ab0ANLIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:08:44 -0500
In-Reply-To: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Thu, 14 Jan 2010 02:43:03 -0800

>   Series of 4 small patches to fix endianness issues and License header.
>   These issues were suggested by Ben Hutchings for qlcnic driver,
>   same apply to netxen_nic driver.
>   Please apply these patches in net-2.6 tree.

These endianness fixes for netxen are starting to get reduclious.

You mean in all this time, nobody noticed that reading the MAC
address isn't done correctly on big-endian?

Well then I guess all of these small endianness fixes aren't
very critical this late in the RC series.

I want to start slimming down the amount of small driver fixes
that are still being submitted this late.  And these endian
bits that show the device is basically unused by anyone (perhaps
other than you) on big endian are a good way to start.

Submit them for net-next-2.6 of course, but I'm tossing this
series for net-2.6, sorry.

