From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qlcnic: Bug fixes
Date: Tue, 05 Aug 2014 16:24:02 -0700 (PDT)
Message-ID: <20140805.162402.1902639431720311788.davem@davemloft.net>
References: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaHEXYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:24:03 -0400
In-Reply-To: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Mon, 4 Aug 2014 11:51:15 -0400

> The patch series contains following bug fixes.
> 
> * Aggregating tx stats in adapter variable was resulting
>   in increase of stats when user runs ifconfig command
>   and no traffic is running. Instead aggregate tx stats
>   in local variable and then assign it to adapter struct
>   variable.
> * Set_driver_version was called after registering netdev
>   which was resulting in a race between FLR in open
>   handler and set_driver_version command as open handler
>   can be called simulatneously on another cpu even if probe
>   is not complete. So call this command before registering
>   netdev.
> * dcbnl_ops should be initialized before registering netdev
>   as they are referenced in open handler.
>    
> Please apply this series to net.

Series applied, thanks.
