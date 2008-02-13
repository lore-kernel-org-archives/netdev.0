From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NETLABEL]: Don't produce unused variables when
 IPv6 is off.
Date: Tue, 12 Feb 2008 22:37:33 -0800 (PST)
Message-ID: <20080212.223733.253093661.davem@davemloft.net>
References: <47AB3EBF.2090300@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753412AbYBMGhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:37:02 -0500
In-Reply-To: <47AB3EBF.2090300@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 07 Feb 2008 20:24:15 +0300

> Some code declares variables on the stack, but uses them
> under #ifdef CONFIG_IPV6, so thay become unused when ipv6
> is off. Fortunately, they are used in a switch's case
> branches, so the fix is rather simple.
> 
> Is it OK from coding style POV to add braces inside "cases",
> or should I better avoid such style and rework the patch?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
