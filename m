From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] igb: remove skb_orphan calls
Date: Mon, 02 Mar 2009 16:02:01 -0800 (PST)
Message-ID: <20090302.160201.56279333.davem@davemloft.net>
References: <20090302234337.12241.52123.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758862AbZCCACU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 19:02:20 -0500
In-Reply-To: <20090302234337.12241.52123.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 02 Mar 2009 15:44:04 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Remove skb_orphan call from igb driver as it can cause multiple issues due
> to the fact that it is calling the desctructor and removing the skb from
> the socket prior to transmission.
> 
> The call was added to improve performance but did so by allowing the skb to
> be removed from the socket which gave the socket more window space to
> transmit.  The performance gain is not worth the extra problems that this
> kind of workaround can introduce as this could lead to a potential DoS if a
> UDP stream decided to monopolize the transmit path.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
