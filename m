From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove driver_data direct access of struct device
Date: Fri, 01 May 2009 15:22:19 -0700 (PDT)
Message-ID: <20090501.152219.110421191.davem@davemloft.net>
References: <20090430221931.GA18557@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753222AbZEAWWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:22:25 -0400
In-Reply-To: <20090430221931.GA18557@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>
Date: Thu, 30 Apr 2009 15:19:31 -0700

> In the near future, the driver core is going to not allow direct access
> to the driver_data pointer in struct device.  Instead, the functions
> dev_get_drvdata() and dev_set_drvdata() should be used.  These functions
> have been around since the beginning, so are backwards compatible with
> all older kernel versions.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Applied to net-next-2.6, thanks.
