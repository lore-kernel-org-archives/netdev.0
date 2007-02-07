From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unregister_netdevice as void
Date: Wed, 07 Feb 2007 00:10:14 -0800 (PST)
Message-ID: <20070207.001014.99829679.davem@davemloft.net>
References: <20061218155057.1904f666@freekitty>
	<20061218.173745.08333482.davem@davemloft.net>
	<20061218210511.7064547c@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, benjamin.li@qlogic.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965678AbXBGIKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:10:15 -0500
In-Reply-To: <20061218210511.7064547c@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 18 Dec 2006 21:05:11 -0800

> There was no real useful information from the unregister_netdevice() return
> code, the only error occurred in a situation that was a driver bug. So
> change it to a void function.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied to net-2.6.21, thanks Stephen.
