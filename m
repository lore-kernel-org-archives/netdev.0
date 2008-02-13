From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][GENETLINK]: Relax dances with genl_lock.
Date: Tue, 12 Feb 2008 22:16:44 -0800 (PST)
Message-ID: <20080212.221644.107209578.davem@davemloft.net>
References: <47B1D45D.3020409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbYBMGQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:16:13 -0500
In-Reply-To: <47B1D45D.3020409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 12 Feb 2008 20:16:13 +0300

> The genl_unregister_family() calls the genl_unregister_mc_groups(), 
> which takes and releases the genl_lock and then locks and releases
> this lock itself.
> 
> Relax this behavior, all the more so the genl_unregister_mc_groups() 
> is called from genl_unregister_family() only.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Ok, applied, thanks.
