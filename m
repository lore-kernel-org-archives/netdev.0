From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Subject: Re: [PATCH] net/9p: convert to new CQ API
Date: Sun, 28 Feb 2016 13:03:47 +0200
Message-ID: <56D2D413.7080008@dev.mellanox.co.il>
References: <1456565151-27115-1-git-send-email-hch@lst.de>
 <1456565151-27115-2-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36339 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041AbcB1LDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 06:03:52 -0500
Received: by mail-wm0-f42.google.com with SMTP id n186so12540859wmn.1
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 03:03:51 -0800 (PST)
In-Reply-To: <1456565151-27115-2-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Trivial conversion to the new RDMA CQ API.

Looks nice and simple :)

But I think that the fact that CQ processing is now
done in soft-IRQ (which is an improvement!) needs to
be documented.

Other than that, looks great

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>

P.S.
I was also confused in the past about 9p and if anyone
actually uses it...
