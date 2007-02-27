From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3+/4] bridge: fix locking of set path cost
Date: Tue, 27 Feb 2007 09:56:03 -0800 (PST)
Message-ID: <20070227.095603.18302562.davem@davemloft.net>
References: <20070221224107.741532037@linux-foundation.org>
	<20070221224255.790379091@linux-foundation.org>
	<20070227095251.0c20eebd@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org,
	Aji_Srinivas@emc.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751367AbXB0R4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 12:56:06 -0500
In-Reply-To: <20070227095251.0c20eebd@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 27 Feb 2007 09:52:51 -0800

> This change goes with earlier change to get rid of 
> work queue for path cost. Now stp_set_path_cost does its own
> locking. This is to allow it to call br_path_cost() which calls
> ethtool interfaces (might sleep).
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
