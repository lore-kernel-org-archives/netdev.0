From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 22:25:59 +0200
Message-ID: <20070318202559.GD11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	Roland Dreier <rolandd@cisco.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:16527 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933114AbXCRUZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 16:25:18 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1141291uga
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 13:25:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070318191238.GA20518@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Why is neighbour->dev changed here?
> 
> It holds reference to device and prevents its destruction.
> If dst is held somewhere, we cannot destroy the device and deadlock
> while unregister.

BTW, can this ever happen for the loopback device itself?
Is it ever unregistered?

-- 
MST
