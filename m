From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: add client name to port profile
Date: Wed, 01 Oct 2014 21:55:37 -0400 (EDT)
Message-ID: <20141001.215537.1507274034523758286.davem@davemloft.net>
References: <1412114357-11557-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbaJBBzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 21:55:39 -0400
In-Reply-To: <1412114357-11557-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed,  1 Oct 2014 03:29:17 +0530

> Firmware has support for sending client name of the port profile to the switch
> it's connected to.
> 
> This patch adds client name to port profile which is sent to hardware while
> associating a port profile to VF.
> 
> Since port profile are defined in switch, this patch makes it easier to check
> what VM is using a port profile.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

I think you should split this up into two patches, one which adds
the new netlink facility, and second which adds support to the
specific driver.

Thanks.
