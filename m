From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 6/6] r8169: print errors when dma mapping fail
Date: Fri, 15 Oct 2010 16:52:01 +0200
Message-ID: <20101015145201.GB4417@electric-eye.fr.zoreil.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
 <1287144922-3297-6-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Kirjanov <kirjanov@gmail.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-139-115-126.adslgp.cegetel.net ([88.139.115.126]:54796 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755837Ab0JOOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 10:52:47 -0400
Content-Disposition: inline
In-Reply-To: <1287144922-3297-6-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> :
> Print errors because dma mapping failures can cause device to stop
> working and will need user intervention to recover.

I am hesitating (overengineered ? bloaty ? not the right place ?).

The Tx stats are kept up-to-date : Tx failure will go along a Tx drop
stat increase.

Regarding a mapping failure in the Rx path, either it will behave as
an allocation failure at open / resume time - and I have no idea how
the user will recover - or it will happen during a Rx ring refill.

...

Ok, something could have gone unnoticed. Let's try it.

-- 
Ueimor
