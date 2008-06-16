From: jes@trained-monkey.org (Jes Sorensen)
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Mon, 16 Jun 2008 12:25:10 -0400
Message-ID: <18518.37862.812419.353804@jaguar.mkp.net>
References: <1213608300.26255.665.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaswinder@infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaguar.mkp.net ([192.139.46.146]:55232 "EHLO jaguar.mkp.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776AbYFPQZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 12:25:11 -0400
In-Reply-To: <1213608300.26255.665.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Woodhouse <dwmw2@infradead.org> writes:

David> Again with help from Jaswinder Singh.  Omitting the large part of
David> the patch which actually moves the firmware around, since you'll
David> need to pull from the git tree to get the preceding patches if
David> you want to test it anyway.

David> We store the firmware in little-endian form now, and thus use
David> __raw_writel() to write it to the device, to avoid byteswapping
David> by writel(). I've revamped that loop in ace_copy() a little bit
David> so it could probably do with being tested.

Mmmmm,

I am not particular bothered as to whether or not to put the firmware to
userspace or not, however has this patch been tested on big endian
systems? Given that the card is big endian, how is this going to affect
big endian systems?

Honestly, I think it's a bad idea to start messing with the byte order
of the data for something that happens once at boot time.

Cheers,
Jes
