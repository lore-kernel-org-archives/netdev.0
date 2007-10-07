From: Andreas Mohr <andi@lisas.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
	ISDN
Date: Sun, 7 Oct 2007 19:20:37 +0200
Message-ID: <20071007172037.GA29384@rhlx01.hs-esslingen.de>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de> <4708D00D.8030307@garzik.org> <20071007131723.GA22873@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:57080 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbXJGRUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 13:20:38 -0400
Content-Disposition: inline
In-Reply-To: <20071007131723.GA22873@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Oct 07, 2007 at 03:17:24PM +0200, Andreas Mohr wrote:
> I thus decided to now try plain 2.6.23-rc8 whether it's "corrupted", too.

OK, after 3 hours of compilation the ONLY datapoint I can give right now is:
1 (one) boot on 2.6.23-rc8-mm2 had the BUG in /var/log/messages,
1 (one) boot on 2.6.23-rc8 did NOT have it.

The two .config:s (I did a make oldconfig when going back to
non-mm2) don't seem to have any relevant differences.

I could offer to do more testing on this machine,
but this carries a slight risk for me since I (personally) won't have physical
access to it for a couple days and some people will kill me if the main
internet gateway happened to go down unfixably. ;)

Thanks,

Andreas Mohr
