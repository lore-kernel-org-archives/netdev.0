From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: PATCH 0/1: rt2x00dev.c / rt2x00lib.h fixes build breakage
Date: Fri, 25 Sep 2009 00:53:17 -0400
Message-ID: <20090925045316.GB2722@tuxdriver.com>
References: <5a44caba0909231358y23f21c0drb2a3451084028a6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ken Lewis <kennylewis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42938 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbZIYFBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 01:01:12 -0400
Content-Disposition: inline
In-Reply-To: <5a44caba0909231358y23f21c0drb2a3451084028a6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2009 at 09:58:35PM +0100, Ken Lewis wrote:
> The headers in drivers/net/wireless/rt2x00/rt2x00lib.h don't match the
> use of the function in rt2x00dev.c  The build fails as a result.
> 
> This has been a problem in linux-next since early September.  I've
> e-mailed a patch to linux-next and to linux-net, but the 2.6.32 merge
> window has brought the problem to the mainline and so I'm re-sending
> my patch.  I've opened a bug on bugzilla:
> http://bugzilla.kernel.org/show_bug.cgi?id=14217

Always make sure to send wireless LAN patches to
linux-wireless@vger.kernel.org.  Anyway, the following patch is in
the pull request I sent to Dave yesterday (and which I believe he
has already pulled):

commit fe2475633676b0a976400dfc53f8d7006f56543e
Author: Andrew Price <andy@andrewprice.me.uk>
Date:   Thu Sep 17 21:15:48 2009 +0100

    rt2x00: fix the definition of rt2x00crypto_rx_insert_iv
    
    Remove the redundant l2pad parameter from the definition of
    rt2x00crypto_rx_insert_iv which is used when only CONFIG_RT2500PCI but
    none of the other rt2x00 family drivers is configured.
    
    Signed-off-by: Andrew Price <andy@andrewprice.me.uk>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

Hth!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
