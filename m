From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/7] Make __devinet_sysctl_register return
 an error
Date: Sun, 16 Dec 2007 13:30:15 -0800 (PST)
Message-ID: <20071216.133015.126991672.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ECD7C.8050905@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758333AbXLPVaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:30:22 -0500
In-Reply-To: <475ECD7C.8050905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:48:44 +0300

> Currently, this function is void, so failures in creating
> sysctls for new/renamed devices are not reported to anywhere.
> 
> Fixing this is another complex (needed?) task, but this
> return value is needed during the namespaces creation to
> handle the case, when we failed to create "all" and "default"
> entries.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
