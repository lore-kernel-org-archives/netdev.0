From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ip: local port range robustness
Date: Wed, 10 Oct 2007 17:43:50 -0700 (PDT)
Message-ID: <20071010.174350.104031474.davem@davemloft.net>
References: <20071011000020.907277335@linux-foundation.org>
	<20071011000042.692751658@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757041AbXJKAnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 20:43:47 -0400
In-Reply-To: <20071011000042.692751658@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 10 Oct 2007 17:00:22 -0700

> Expansion of original idea from Denis V. Lunev <den@openvz.org>
> 
> Add robustness and locking to the local_port_range sysctl.
> 1. Enforce that low < high when setting.
> 2. Use seqlock to ensure atomic update.
> 
> The locking might seem like overkill, but there are
> cases where sysadmin might want to change value in the
> middle of a DoS attack.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
