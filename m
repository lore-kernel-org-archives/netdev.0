From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: tg3 stops working when NFS is involved
Date: Mon, 8 Jun 2009 10:21:08 -0700 (PDT)
Message-ID: <alpine.DEB.2.01.0906081013530.6439@bogon>
References: <alpine.DEB.2.01.0906072115420.6439@bogon> <alpine.DEB.2.01.0906072215000.6439@bogon> <20090608164038.GA8825@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:54507 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbZFHRVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 13:21:15 -0400
In-Reply-To: <20090608164038.GA8825@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2009, Matt Carlson wrote:
> This seems to be a common problem with the 5906 on some
> notebooks.  The word on the street is that turning sg off through
> ethtool seems to avoid the problem.

Well, I must've been on the wrong streets then, this was news to me...

> While I dig deeper into this
> problem, you could try that and see if it helps you.

Yes, "ethtool -K eth0 sg off" does indeed help here too: I've already 
transmitted a few gigabytes of traffic (the problem occured after a few 
megabytes lastly) and all is still well.

Thanks for your quick response!
Christian.
-- 
BOFH excuse #273:

The cord jumped over and hit the power switch.
