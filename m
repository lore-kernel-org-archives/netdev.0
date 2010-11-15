From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] offloading: Make scatter/gather more tolerant of
 vlans.
Date: Mon, 15 Nov 2010 09:23:37 -0800 (PST)
Message-ID: <20101115.092337.115944173.davem@davemloft.net>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35779
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932303Ab0KORXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:23:13 -0500
In-Reply-To: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 29 Oct 2010 15:14:53 -0700

> When checking if it is necessary to linearize a packet, we currently
> use vlan_features if the packet contains either an in-band or out-
> of-band vlan tag.  However, in-band tags aren't special in any way
> for scatter/gather since they are part of the packet buffer and are
> simply more data to DMA.  Therefore, only use vlan_features for out-
> of-band tags, which could potentially have some interaction with
> scatter/gather.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
