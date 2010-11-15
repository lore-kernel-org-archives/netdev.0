From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] offloading: Force software GSO for multiple vlan
 tags.
Date: Mon, 15 Nov 2010 09:23:49 -0800 (PST)
Message-ID: <20101115.092349.260082562.davem@davemloft.net>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
	<1288390495-28923-3-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932303Ab0KORXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:23:24 -0500
In-Reply-To: <1288390495-28923-3-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 29 Oct 2010 15:14:55 -0700

> We currently use vlan_features to check for TSO support if there is
> a vlan tag.  However, it's quite likely that the NIC is not able to
> do TSO when there is an arbitrary number of tags.  Therefore if there
> is more than one tag (in-band or out-of-band), fall back to software
> emulation.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
