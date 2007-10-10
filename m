From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET-2.6.24] Remove double dev->flags checking when
 calling dev_close()
Date: Wed, 10 Oct 2007 02:49:28 -0700 (PDT)
Message-ID: <20071010.024928.32347244.davem@davemloft.net>
References: <470B5D0E.9090202@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753950AbXJJJtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:49:25 -0400
In-Reply-To: <470B5D0E.9090202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 14:50:54 +0400

> The unregister_netdevice() and dev_change_net_namespace() 
> both check for dev->flags to be IFF_UP before calling the 
> dev_close(), but the dev_close() checks for IFF_UP itself, 
> so remove those unneeded checks.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
