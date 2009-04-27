From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: prevent oops caused by netdev destructor
Date: Mon, 27 Apr 2009 03:05:15 -0700 (PDT)
Message-ID: <20090427.030515.184629602.davem@davemloft.net>
References: <20090423214120.22bcc680@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753790AbZD0KFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:05:22 -0400
In-Reply-To: <20090423214120.22bcc680@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 23 Apr 2009 21:41:20 -0700

> The veth driver will oops if sysfs hooks are open while module is removed.
> 
> The net device destructor can not point to code in a module; basically
> there are only two possible safe values: NULL - no destructor, or
> free_netdev - free on last use

Applied.

Please provide a proper signoff next time.

Thanks!
