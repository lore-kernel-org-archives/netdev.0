From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: systemport: RX path and suspend fixes
Date: Tue, 28 Oct 2014 17:11:41 -0400 (EDT)
Message-ID: <20141028.171141.186647358470811298.davem@davemloft.net>
References: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbaJ1VLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:11:43 -0400
In-Reply-To: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 28 Oct 2014 11:11:59 -0700

> These two patches fix a race condition where we have our RX interrupts
> enabled, but not NAPI for the RX path, and the second patch fixes an
> issue for packets stuck in RX fifo during a suspend/resume cycle.

Series applied, thanks.
