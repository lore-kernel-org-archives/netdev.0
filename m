From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] Add missed tunnel64_err handler
Date: Sat, 10 Nov 2007 21:48:24 -0800 (PST)
Message-ID: <20071110.214824.32316967.davem@davemloft.net>
References: <47345D24.7010603@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48497
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbXKKFsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:48:25 -0500
In-Reply-To: <47345D24.7010603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 09 Nov 2007 16:14:12 +0300

> The tunnel64_protocol uses the tunnel4_protocol's err_handler and
> thus calls the tunnel4_protocol's handlers.
> 
> This is not very good, as in case of (icmp) error the wrong error
> handlers will be called (e.g. ipip ones instead of sit) and this
> won't be noticed at all, because the error is not reported.
> 
> Was that made deliberately and I miss something?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This definitely was doing the wrong thing for the SIT
case, for example.  So this looks legitimate to me.

Patch applied, thanks!
