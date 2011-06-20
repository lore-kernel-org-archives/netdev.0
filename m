From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri_sbus: remove driver
Date: Mon, 20 Jun 2011 12:51:33 -0700 (PDT)
Message-ID: <20110620.125133.311330932319985237.davem@davemloft.net>
References: <20110620193859.GA19114@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	gallatin@myri.com
To: jon.mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab1FTTvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 15:51:53 -0400
In-Reply-To: <20110620193859.GA19114@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@myri.com>
Date: Mon, 20 Jun 2011 14:39:00 -0500

> Remove the myri_sbus driver. Why?
> * There is no possibility of ethernet mode on this adapter, so it's
>   Myrinet only.
> * It won't inter-op with modern versions of Myrinet, and thus can only
>   work with legacy adapters.
> * There are no in-kernel Linux drivers for the PCI version of this
>   adapter, so it only can work on ~15 year old Sun hardware.
> 
> It's long in the tooth, let's take it to the knackers.
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Sniff sniff... applied.
