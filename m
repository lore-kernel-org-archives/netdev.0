From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] openvswitch: Initialize unmasked key and
 uid len
Date: Sun, 08 Feb 2015 00:51:39 -0800 (PST)
Message-ID: <20150208.005139.1948138670775583601.davem@davemloft.net>
References: <1423250233-1529-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joestringer@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbbBHIvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 03:51:42 -0500
In-Reply-To: <1423250233-1529-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri,  6 Feb 2015 11:17:13 -0800

> Flow alloc needs to initialize unmasked key pointer. Otherwise
> it can crash kernel trying to free random unmasked-key pointer.
 ...
> Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
> CC: Joe Stringer <joestringer@nicira.com>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
