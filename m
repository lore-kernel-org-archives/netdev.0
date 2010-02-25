From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 02:18:22 -0800 (PST)
Message-ID: <20100225.021822.66777947.davem@davemloft.net>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com,
	dhowells@redhat.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36793
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759011Ab0BYKSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 05:18:05 -0500
In-Reply-To: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Thu, 25 Feb 2010 14:08:34 +0100

> Memory barriers here IMHO, prevent to make queue permanently stopped
> when on one cpu bnx2x_tx_int() make queue empty, whereas on other
> cpu bnx2x_start_xmit() see it full and make stop it, such cause
> queue will be stopped forever.

Instead of having an opinion, please show the exact sequence
of events that can lead to this situation.  With such facts
inhand, you will have no need for an opinion :-)
