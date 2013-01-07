From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] ethoc: fix mac address set
Date: Sun, 06 Jan 2013 21:04:42 -0800 (PST)
Message-ID: <20130106.210442.2268531393641932718.davem@davemloft.net>
References: <1357478745-19923-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab3AGFEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:04:43 -0500
In-Reply-To: <1357478745-19923-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  6 Jan 2013 14:25:45 +0100

> Function ethoc_set_mac_address() was incorrectly using passed pointer as
> pointer to address, that is not correct.
> Struct sockaddr have to be be used here.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

This only applies to the net-next tree, so that's where I've
added it.
