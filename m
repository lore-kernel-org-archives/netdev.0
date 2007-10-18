From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Lost locking when inserting a flowlabel in
 ipv6_fl_list
Date: Thu, 18 Oct 2007 05:15:07 -0700 (PDT)
Message-ID: <20071018.051507.21365059.davem@davemloft.net>
References: <471748CD.2030808@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754563AbXJRMOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:14:53 -0400
In-Reply-To: <471748CD.2030808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 15:51:41 +0400

> The new flowlabels should be inserted into the sock list
> under the ip6_sk_fl_lock. This was lost in one place.
> 
> This list is naturally protected with the socket lock, but
> the fl6_sock_lookup() is called without it, so another
> protection is required.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
