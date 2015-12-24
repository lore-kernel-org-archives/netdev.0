From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: mv88e6xxx: Add Second back of statistics
Date: Wed, 23 Dec 2015 22:17:22 -0500 (EST)
Message-ID: <20151223.221722.978052030657066229.davem@davemloft.net>
References: <1450873397-19947-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivian@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368AbbLXDRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:17:24 -0500
In-Reply-To: <1450873397-19947-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 23 Dec 2015 13:23:17 +0100

> The 6320 family of switch chips has a second bank for statistics, but
> is missing three statistics in the port registers. Generalise and
> extend the code:
> 
> * adding a field to the statistics table indicating the bank/register
>   set where each statistics is.
> * add a function indicating if an individual statistics
>   is available on this device
> * calculate at run time the sset_count.
> * return strings based on the available statistics of the device
> * return statistics based on the available statistics of the device
> * Add support for reading from the second bank.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
