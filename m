From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Notify changes in UDP encapsulation via netlink
Date: Tue, 28 Oct 2008 11:48:28 -0700 (PDT)
Message-ID: <20081028.114828.158507859.davem@davemloft.net>
References: <20081028085119.6A30EEF9BA@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752171AbYJ1Ssv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 14:48:51 -0400
In-Reply-To: <20081028085119.6A30EEF9BA@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin@strongswan.org (Martin Willi)
Date: Tue, 28 Oct 2008 09:51:19 +0100 (CET)

> Add new_mapping() implementation to the netlink xfrm_mgr to notify
> address/port changes detected in UDP encapsulated ESP packets.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>

I don't see the code which will actually invoke the new
->new_mapping() method (either here or in a follow-on patch), so it's
impossible to review these changes.
