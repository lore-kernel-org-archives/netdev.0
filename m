From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/3] netxen: remove duplicate napi_add
Date: Thu, 03 Sep 2009 20:07:19 -0700 (PDT)
Message-ID: <20090903.200719.210860351.davem@davemloft.net>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
	<1252019455-30683-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932735AbZIDDHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:07:04 -0400
In-Reply-To: <1252019455-30683-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu,  3 Sep 2009 16:10:54 -0700

> Remove duplicate calls to netxen_napi_add().
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, but:

> @@ -2038,8 +2034,6 @@ netxen_remove_sysfs_entries(struct netxen_adapter *adapter)
>  		device_remove_file(dev, &dev_attr_bridged_mode);
>  }
>  
> -static void netxen_watchdog(unsigned long);
> -
>  #ifdef CONFIG_INET
>  
>  #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)

Give me a friggin' break, really.

If you're going to slip unrelated cleanups like this into your
patches, at least DOCUMENT them in the commit message.
