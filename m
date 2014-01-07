From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv4: loopback device: ignore value changes
 after device is upped
Date: Tue, 07 Jan 2014 15:55:49 -0500 (EST)
Message-ID: <20140107.155549.98588086439574944.davem@davemloft.net>
References: <1389106545-7940-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaAGUzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:55:52 -0500
In-Reply-To: <1389106545-7940-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  7 Jan 2014 15:55:45 +0100

> When lo is brought up, new ifa is created. Then, devconf and neigh values
> bitfield should be set so later changes of default values would not
> affect lo values.
> 
> Note that the same behaviour is in ipv6. Also note that this is likely
> not an issue in many distros (for example Fedora 19) because userspace
> sets address to lo manually before bringing it up.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks good, applied.
