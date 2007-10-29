From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] skye/skge: sparse fix - data can't ever be bigger than
 LONG_MAX / HZ
Date: Mon, 29 Oct 2007 11:48:33 -0400
Message-ID: <472600D1.6020503@garzik.org>
References: <20071026221028.1873.3005.stgit@localhost.localdomain>	<4725B05A.9050507@garzik.org> <20071029083210.0e2c75a0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60732 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667AbXJ2Psg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 11:48:36 -0400
In-Reply-To: <20071029083210.0e2c75a0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Since these all use ethtool, shouldn't the checks be put into ethtool_phys_id
> rather than having the driver check?

Seems quite reasonable to me.

	Jeff


