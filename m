From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] veth: Remove useless veth field
Date: Tue, 28 Oct 2008 22:08:26 -0700 (PDT)
Message-ID: <20081028.220826.257822236.davem@davemloft.net>
References: <20081028211142.359911603@fr.ibm.com>
	<20081028212115.952319593@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751351AbYJ2FIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:08:48 -0400
In-Reply-To: <20081028212115.952319593@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 28 Oct 2008 22:11:43 +0100

> The veth private structure contains a netdev pointer refering to its peer.
> This field is never used and it is pointless because if we can access,
> the veth_priv, that means we already have the netdev which is stored
> in veth_priv->dev.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
