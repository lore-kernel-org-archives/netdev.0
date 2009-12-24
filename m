From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/4] igb: do not force retry count to 1 on
 82580 phy
Date: Wed, 23 Dec 2009 20:55:27 -0800 (PST)
Message-ID: <20091223.205527.35050037.davem@davemloft.net>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
	<20091223232107.16146.15573.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574AbZLXEzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:55:25 -0500
In-Reply-To: <20091223232107.16146.15573.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Dec 2009 15:21:07 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change resolves an issue seen in some configurations where the link
> may drop to 100Mb/s even though the link itself supports 1000Mb/s.  The
> issue was root caused to the fact that we were only trying the link once.
> Now instead we will try up to 5 attempts on a faulty cable before
> downshifting to 100Mb/s.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
