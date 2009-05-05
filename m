From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove driver_data direct access of struct device
 from more drivers
Date: Mon, 04 May 2009 21:33:30 -0700 (PDT)
Message-ID: <20090504.213330.265648350.davem@davemloft.net>
References: <20090504200145.GA22855@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@redhat.com, themann@de.ibm.com,
	tklein@de.ibm.com, greg@kroah.com
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247AbZEEEdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 00:33:35 -0400
In-Reply-To: <20090504200145.GA22855@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>
Date: Mon, 4 May 2009 13:01:45 -0700

> In the near future, the driver core is going to not allow direct access
> to the driver_data pointer in struct device.  Instead, the functions
> dev_get_drvdata() and dev_set_drvdata() should be used.  These functions
> have been around since the beginning, so are backwards compatible with
> all older kernel versions.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Applied to net-next-2.6, thanks!
