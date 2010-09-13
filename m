From: David Miller <davem@davemloft.net>
Subject: Re: [33-stable regression ssb/broadcom]
Date: Mon, 13 Sep 2010 12:23:29 -0700 (PDT)
Message-ID: <20100913.122329.39186333.davem@davemloft.net>
References: <4C8E6192.2010003@mandriva.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, gregkh@suse.de, Larry.Finger@lwfinger.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tmb@mandriva.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755050Ab0IMTXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 15:23:11 -0400
In-Reply-To: <4C8E6192.2010003@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Backlund <tmb@mandriva.org>
Date: Mon, 13 Sep 2010 20:38:26 +0300

> In Mandriva 2010.1 we noticed that 2.6.33.7 broke ssb/Broadcom lan for
> several users...
> 
> Issue is tracked at:
> https://qa.mandriva.com/show_bug.cgi?id=60968
> 
> Reverting the commit restores a working lan.
> 
> The offending commit is:

Please always CC: netdev on networking reports, otherwise you are
very unlikely to get any experts looking into your issue.

> --- cut ---
> From 6fb037c2ed8378c7ab0c1e00536ba6b2a866503e Mon Sep 17 00:00:00 2001
> From: Christoph Fritz <chf.fritz@googlemail.com>
> Date: Sun, 11 Jul 2010 18:26:15 -0500
> Subject: [PATCH] ssb: Handle Netbook devices where the SPROM address
> is changed
> 
> For some Netbook computers with Broadcom BCM4312 wireless interfaces,
> the SPROM has been moved to a new location. When the ssb driver tries
> to
> read the old location, the systems hangs when trying to read a
> non-existent location. Such freezes are particularly bad as they do
> not
> log the failure.
> 
> This patch is modified from commit
> da1fdb02d9200ff28b6f3a380d21930335fe5429 with some pieces from other
> mainline changes so that it can be applied to stable 2.6.34.Y.
> --- cut ---
> 
> --
> Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
