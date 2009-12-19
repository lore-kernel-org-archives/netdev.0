From: David Miller <davem@davemloft.net>
Subject: Re: NetXen crash in sysfs_create_file
Date: Fri, 18 Dec 2009 20:14:00 -0800 (PST)
Message-ID: <20091218.201400.260092381.davem@davemloft.net>
References: <200912181324.29906.bjorn.helgaas@hp.com>
	<20091218162054.7b19d98f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn.helgaas@hp.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755025AbZLSEN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:13:59 -0500
In-Reply-To: <20091218162054.7b19d98f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Dec 2009 16:20:54 -0800

> Subject: [PATCH] netxen: use module parameter correctly
> 
> Netxen driver is doing this bogus thing to create a control file.
> This fails if device doesn't exist, and overall is a bad way to do
> the module parameter. Rather than fix borked code, just rewrite.
> Just using a writeable module parameter of 0/1 is the correct way
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
