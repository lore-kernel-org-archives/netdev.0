From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: replace ds with ps where
 possible
Date: Sun, 01 May 2016 19:51:38 -0400 (EDT)
Message-ID: <20160501.195138.301600420204606272.davem@davemloft.net>
References: <1461893046-28200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbcEAXvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:51:41 -0400
In-Reply-To: <1461893046-28200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 28 Apr 2016 21:24:06 -0400

> From: Andrew Lunn <andrew@lunn.ch>
> 
> The dsa_switch structure ds is actually needed in very few places,
> mostly during setup of the switch. The private structure ps is however
> needed nearly everywhere. Pass ps, not ds internally.
> 
> [vd: rebased Andrew's patch.]
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.

Andrew, please, when replying to a patch posting do not quote the entire
patch when you're just commenting about the commit message or a small
part of the change.  Thanks.
