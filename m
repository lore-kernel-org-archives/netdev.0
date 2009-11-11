From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Set link down initially for drivers that
 update link state
Date: Tue, 10 Nov 2009 22:31:02 -0800 (PST)
Message-ID: <20091110.223102.161986775.davem@davemloft.net>
References: <1257384592.3136.473.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, greg@kroah.com, jacmet@sunsite.dk,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752345AbZKKGag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:30:36 -0500
In-Reply-To: <1257384592.3136.473.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 05 Nov 2009 01:29:52 +0000

> Some usbnet drivers update link state while others do not due to
> hardware limitations.  Add a flag to distinguish those that do, and
> set the link down initially for their devices.
> 
> This is intended to fix this bug: http://bugs.debian.org/444043
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied to net-next-2.6
