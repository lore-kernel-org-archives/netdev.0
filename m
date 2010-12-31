From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: Do not use legacy PCI power management
Date: Fri, 31 Dec 2010 12:50:32 -0800 (PST)
Message-ID: <20101231.125032.200373631.davem@davemloft.net>
References: <201012261944.32517.rjw@sisk.pl>
	<20101230105229.189f3737@nehalam>
	<201012302350.01205.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753156Ab0LaUuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:50:01 -0500
In-Reply-To: <201012302350.01205.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 30 Dec 2010 23:50:01 +0100

> On Thursday, December 30, 2010, Stephen Hemminger wrote:
>> The skge driver used the legacy PCI power management, and did its
>> own PCI callbacks.  Use the same code model as Rafael's changes to
>> sky2. Let the PCI subsystem take care of all the PCI-specific aspects of
>> device handling during system power transitions.
>> 
>> Compile tested only (so far).
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied to net-next-2.6, thanks!
